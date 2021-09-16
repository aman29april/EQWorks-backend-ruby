# README

## EQWorks - Backend Track Ruby on Rails

This is API only Ruby on Rails based application solution to EQWork's [ws-product](https://gist.github.com/woozyking/126fdf4c72fdf65a3504e5681a1ce715) challenge.
This is a MVP product with minimum functionalities.

### Live Demo
Live demo can be found at
**[GET events from memory](https://stark-fjord-10885.herokuapp.com/api/events)**

**[GET events from Mock Store](https://stark-fjord-10885.herokuapp.com/api/events?store=true)**


### Tech Stack
* Ruby (3.0.2)
* Rails (6.1.4)
* Redis

### Running Locally
Make sure above requirements are fulfilled before running this application.
Navigate to project directory and follow following commands

`bundle install` will install all the required gems.

`rails server` Rails Server will start and you can visit `localhost:3000` in your web browser.

### Running Tests
Run `rails spec` command from project folder.

### API End Points
**`POST` `/api/events`**
Params:
event[name]=EVENT_NAME
event[type]=EVENT_TYPE

example value for name: music
Supported values for type: clicks, views

CURL Sample:
```
curl -L -X POST 'http://localhost:3000/api/events' -F 'event[name]=music' -F 'event[type]=clicks'
```

**`GET` `/api/events`** To view events that are logged.
This API takes optional parameter `store`. If store is present, API will return events from Store else memory.
`/api/events?store=true`

## Design

### 1. Data structure

- `LocalCounterStore` class is used to store counters in memory.
- Hash Data structure is used. 
  - Event name is the key and has a nested hash as value. Time will be the key and value will be hash of views and clicks.
  - Events with same time (date, hours, minutes) will be under same time key. 
  - Below is sample hash.
```json 
{
    "events": {
        "music": {
            "2021-09-16 20:21": {
                "views": 0,
                "clicks": 2,
                "time": "2021-09-16 20:21",
                "key": "music:2021-09-16 20:21",
                "name": "music"
            }
        }
    }
}
```

### 2. Mock store
- I am using `Redis` to store values of the counters. For this redis hash is being used. Key of the hash is event name with time, example: `"music:2021-09-16 20:20"` and value will be hash of views and clicks `"{"clicks":10,"views":0}"`
- `app/services/redis_counter_store.rb` Module is being used for store.
- Below is sample output when we get all values from Redis Store and return in GET API
```json
"events": {
  "music:2021-09-16 20:20": "{\"clicks\":10,\"views\":0}",
  "music:2021-09-16 20:21": "{\"clicks\":3,\"views\":0}"
}
```

### 3. Goroutine
- To upload counters, First i thought to use `ConJob`, but it has limitation of a minute.
- So another solution was to create a infinite task with a loop and sleep of 5 seconds.
- **Current Approach**: I am using `TimerTask`, which will run the code in threads. `TimerTask` thread can respond to the success or failure of the task, performing logging operations and
can also be configured with a timeout value allowing it to kill a task that runs too long.
  - In initializers `config/initializers/routine.rb` there is code to run Task after every 5 seconds and for now timeout is also 5 seconds.


### 4. Global rate-limiting
- `RateLimiter` class `app/services/rate_limiter.rb` is used for rate limiting. I am using `redis` to store the counters. 
- `MAX_REQUESTS_LIMIT` and `MAX_REQUEST_DURATION` ENV variables are used to configure rate limiting with default values `10` and `1` respectively.
- `MAX_REQUESTS_LIMIT` is the number of requests that can be made in last `MAX_REQUEST_DURATION` minutes. So by default `10 requests can be made in a minute`.


### Assumptions
- Time of each event will be set as `server current time`. For some events client may want to set the time, but for now current server time is assumed.
- Two `events with same name and same time` (ignoring seconds) are `merged`. Say there is a click event and we already have similar click event with same time, so clicks of existing event will be incremented.
- Only `views` and `clicks` events are possible right now.
- On each event, count is incremented by 1

### Improvements
- Right now i am using hash to store data, which is not thread safe. Instead we need to use some `thread safe` data structure like `https://github.com/hamstergem/hamster`
- Test Suit is also using same local store variable.
- Routine task starts automatically after initialization and there is no way to stop it. So there should be a mechanism to control execution of the routine
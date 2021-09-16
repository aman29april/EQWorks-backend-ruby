# README

## EQWorks - Backend Track Ruby on Rails

This is API only Ruby on Rails based application solution to EQWork's [ws-product](https://gist.github.com/woozyking/126fdf4c72fdf65a3504e5681a1ce715) challenge.
This is a MVP product with minimum functionalities.

### Live Demo
Live demo can be found at https://stark-fjord-10885.herokuapp.com/

https://stark-fjord-10885.herokuapp.com/api/events


### Tech Stack
* Ruby (3.0.2)
* Rails (6.1.4)
* PostgreSQL (13.3.1)

### Running Locally
Make sure above requirements are fulfilled before running this application.
Navigate to project directory and follow following commands

`bundle install` will install all the required gems.

`rails server` Rails Server will start and you can visit `localhost:3000` in your web browser.

Run Task: `bundle exec rake upload_routine:sync_at_5_sec`
### Running Tests
Run `rails spec` command from project folder.

### Assumptions

### API End Points
**`POST` `/api/events`**

```
curl -X POST "https://{HOST}/api/events" -H  "Content-Type: multipart/form-data" -F "file_report[file]=@{PATH_TO_CSV};type=text/csv"
```
---
**`GET` `/api/payroll_reports`**

```
curl -X GET "http://{HOST}/api/payroll_reports"
```

### Design
* This application API only application built using Ruby on Rails.
* For persistence, **Postgres** is being used. We have structured data and later on, we may want to perform complex queries to generate timesheet and other reports. So I choose SQL based database.

`LocalCounterStore` class is used to store counters in memory. Hash Data structure is used. Event name with time will be the key and value will be hash of views and clicks.
RateLimiter is used for rate limiting. I am using redis to store the counters. MAX_REQUESTS_LIMIT and MAX_REQUEST_DURATION ENV variables are used to configure rate limiting with default values 10 and 1 respectively.
MAX_REQUESTS_LIMIT is the number of requests that can be made in last MAX_REQUEST_DURATION minutes. So by default 10 requests can be made in a minute.

To upload counters, First i thought to use `ConJob`, but it has limitation of a minute. So another solution was to create a infinite task with a loop and sleep of 5 seconds. 
But I choose to create rake task `lib/tasks/upload_routine.rake`. Inside rake task i have used `TimerTask`, which will run the code in threads. `TimerTask` thread can respond to the success or failure of the task, performing logging operations and 
can also be configured with a timeout value allowing it to kill a task that runs too long.



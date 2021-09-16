# README

http://localhost:3000/api/events


## EQWorks - Backend Track Ruby on Rails

This is API only Ruby on Rails based application solution to EQWork's [ws-product](https://gist.github.com/woozyking/126fdf4c72fdf65a3504e5681a1ce715l) challenge.
This is a MVP product with minimum functionalities.

### Live Demo
Live demo can be found at https://sa-payroll.herokuapp.com

### Tech Stack
* Ruby (3.0.2)
* Rails (6.1.4)
* PostgreSQL (13.3.1)

### Running Locally
Make sure above requirements are fulfilled before running this application.
Navigate to project directory and follow following commands

`bundle install` will install all the required gems.

`rails server` Rails Server will start and you can visit `localhost:3000` in your web browser.

### Running Tests
Run `rails spec` command from project folder.

### Assumptions
* Upload CSV file will be in `correct format` and there is no validation on csv rows.
* If csv contains zero records, I am still saving reference of the `report id` in the system, so another csv with same report id can't be uploaded.
* Once CSV is uploaded, `wages` will be calculated based on current `group rates`. If in future group rates change, old entries will have wages as per previous rates.

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

To upload counters, I have a cron job that runs after 5 minutes. It will dump values of inMemory counter to redis.



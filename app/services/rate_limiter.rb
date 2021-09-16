require 'singleton'

class RateLimiter
  RATE_LIMIT_KEY = "#{ENV['RAILS_ENV']}_rateLimit"

  class << self
    def increment
      return false unless user_under_limit?

      $redis.rpush RATE_LIMIT_KEY, Time.now
      true
    end

    def user_under_limit?
      remove_first_expired_request
      $redis.llen(RATE_LIMIT_KEY) < maximum_requests
    end

    def time_limit
      ENV['MAX_REQUEST_DURATION'].to_i
    end

    def maximum_requests
      ENV['MAX_REQUESTS_LIMIT'].to_i
    end

    def cooldown
      first_request_time + time_limit.minutes - Time.now
    end

    def reset
      $redis.del RATE_LIMIT_KEY
    end

    private

    def remove_first_expired_request
      # We can just remove the first request if it is expired
      # and that will make room for a new request
      if $redis.llen(RATE_LIMIT_KEY) > 0 && first_request_time < (Time.now - time_limit.minutes)
        $redis.lpop RATE_LIMIT_KEY
      end
    end

    def first_request_time
      $redis.lindex(RATE_LIMIT_KEY, 0).to_time
    end
  end
end

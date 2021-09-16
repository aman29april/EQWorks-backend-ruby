require 'redis'

Redis.current = Redis.new(url: ENV['REDIS_URL'],
                          db: ENV['REDIS_DB'])

$redis = Redis::Namespace.new('my_app', redis: Redis.current)

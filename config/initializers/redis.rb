require 'redis'

Redis.current = Redis.new(url: ENV['REDIS_URL'],
                          port: ENV['REDIS_PORT'],
                          db: ENV['REDIS_DB'])

$redis = Redis::Namespace.new('my_app', redis: Redis.current)

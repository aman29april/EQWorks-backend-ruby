module RedisCounterStore
  REDIS_HASH_KEY = 'counterk'

  def self.add(key, hash)
    saved_value = $redis.hget(REDIS_HASH_KEY, key)
    if saved_value
      # merge values
      parsed_values = JSON.parse saved_value
      hash[:views] += parsed_values['views']
      hash[:clicks] += parsed_values['clicks']
    end

    $redis.hset(REDIS_HASH_KEY, key, hash.slice(:clicks, :views).to_json)
  end

  def self.events
    $redis.hgetall(REDIS_HASH_KEY)
  end

  def self.delete_all
    $redis.del(REDIS_HASH_KEY)
  end
end

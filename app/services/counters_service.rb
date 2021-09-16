class CountersService
  def self.sync
    @counters.each do |counter|
      saved_value = REDIS.get(counter[:key])
      if saved_value
        # merge values
        values = counter.value
        saved_value[:views] += values[:views]
        saved_value[:clicks] += values[:clicks]
        REDIS.set(key, saved_value)
      else
        REDIS.set(key, saved_value)
      end
    end
  end
end

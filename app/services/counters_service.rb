class CountersService
  def self.sync
    Rails.logger.info 'RUNNING TASK'
    begin
      # here k will be event name like music, sports.
      # value will be hash of time and events.
      LocalCounterStore.events.each do |k, value|
        value.values.each(&method(:save_to_redis))
        LocalCounterStore.remove(k)
      end
    rescue StandardError => e
      Rails.logger.error e.message
    end
  end

  def self.save_to_redis(hash)
    RedisCounterStore.add(hash[:key], hash)
  end
end

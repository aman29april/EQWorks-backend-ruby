class LocalCounterStore
  @@lock = Mutex.new

  class << self
    def add(key, time, value)
      init_counters
      @@counters[key] = {} unless @@counters.has_key? key
      @@counters[key][time] = value
    end

    def init_counters
      @@counters ||= {}
    end

    def get(key, time)
      init_counters
      return unless @@counters.has_key? key

      @@counters[key][time]
    end

    def get_event(key, time)
      opts = get(key, time)
      return if opts.nil?

      Event.new opts
    end

    def remove(key)
      init_counters
      @@counters.delete key
    end

    def events
      init_counters
      @@counters
    end
  end
end

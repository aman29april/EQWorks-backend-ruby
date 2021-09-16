class LocalCounterStore
  include Singleton

  def self.add(key, time, value)
    init_counters
    @@counters[key] = {} unless @@counters.has_key? key
    @@counters[key][time] = value
  end

  def self.init_counters
    @@counters ||= {}
  end

  def self.get(key, time)
    init_counters
    return unless @@counters.has_key? key

    @@counters[key][time]
  end

  def self.get_event(key, time)
    opts = get(key, time)
    return if opts.nil?

    Event.new opts
  end

  def self.remove(key)
    init_counters
    @@counters.delete key
  end

  def self.events
    init_counters
    @@counters
  end
end

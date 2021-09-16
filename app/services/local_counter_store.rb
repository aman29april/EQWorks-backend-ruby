class LocalCounterStore
  include Singleton

  def self.add(key, value)
    init_counters
    @@counters[key] = value
  end

  def self.init_counters
    @@counters ||= {}
  end

  def self.get(key)
    init_counters
    @@counters[key]
  end

  def self.events
    init_counters
    @@counters
  end
end

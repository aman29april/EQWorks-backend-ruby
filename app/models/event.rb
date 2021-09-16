class Event
  include ActiveModel::Validations

  attr_accessor :key, :clicks, :views, :updated_at, :time

  validates :key, :time, presence: true
  validates :clicks, :views, presence: true, numericality: { only_integer: true }

  def initialize(opts = {})
    @clicks = opts[:clicks] || 0
    @views = opts[:views] || 0
    @key = opts[:key]
    @time = opts[:time] || DateUtil.time_key
  end

  def to_json(*_args)
    { views: @views, clicks: @clicks, time: time, key: "#{key}:#{time}" }
  end

  def self.log(attrs)
    time = DateUtil.time_key
    event = LocalCounterStore.get_event(attrs['key'], time) || Event.new(attrs)

    event.clicks += 1 if attrs['type'] == 'clicks'

    event.views += 1 if attrs['type'] == 'views'

    raise_record_invalid unless event.valid?

    LocalCounterStore.add(event.key, time, event.to_json)
  end
end

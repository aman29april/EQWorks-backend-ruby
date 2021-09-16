class Event
  include ActiveModel::Validations

  attr_accessor :key, :event_at, :clicks, :views, :updated_at, :created_at

  validates :key, presence: true
  validates :clicks, :views, presence: true, numericality: { only_integer: true }

  def initialize(opts = {})
    @clicks = 0
    @views = 0
    @created_at = event_at
    @updated_at = event_at
    @key = opts['key']

    # opts.each { |k,v| instance_variable_set("@#{k}", v) }
  end

  def event_at
    Time.now.iso8601
  end

  def to_json(*_args)
    { views: @views, clicks: @clicks, created_at: @created_at, updated_at: @updated_at }
  end

  def self.log(attrs)
    event = LocalCounterStore.get(attrs['key']) || Event.new(attrs)
    event.updated_at = Time.now.iso8601

    event.clicks += 1 if attrs['type'] == 'clicks'

    event.views += 1 if attrs['type'] == 'views'

    raise_record_invalid unless event.valid?

    LocalCounterStore.add(event.key, event)
  end
end

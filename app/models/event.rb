class Event
  include ActiveModel::Validations

  attr_accessor :name, :clicks, :views, :updated_at, :time

  validates :name, :time, presence: true
  validates :clicks, :views, presence: true, numericality: { only_integer: true }

  validate :click_or_view_present

  def initialize(opts = {})
    @clicks = opts[:clicks] || 0
    @views = opts[:views] || 0
    @name = opts[:name]
    @time = opts[:time] || DateUtil.time_key
  end

  def key
    "#{name}:#{time}"
  end

  def to_json(*_args)
    { views: @views, clicks: @clicks, time: time, key: key, name: name }
  end

  def self.log(attrs)
    time = DateUtil.time_key
    event = LocalCounterStore.get_event(attrs['name'], time) || Event.new(attrs)

    event.clicks += 1 if attrs['type'] == 'clicks'

    event.views += 1 if attrs['type'] == 'views'

    raise Exception, event.errors.full_messages.first unless event.valid?

    LocalCounterStore.add(event.name, time, event.to_json)
  end

  private

  def click_or_view_present
    errors.add(:views, 'or Clicks should be present') if views.zero? && clicks.zero?
  end
end

class Api::EventsController < ApplicationController
  # returns counters
  def index
    data = params[:store] ? RedisCounterStore.events : LocalCounterStore.events
    json_response({ events: data })
  end

  def create
    unless RateLimiter.increment
      return json_response({
                             message: 'Event log failed',
                             error: { message: 'Slowdown! You are out of limit',
                                      cooldown: "#{RateLimiter.cooldown} seconds" }
                           }, :unprocessable_entity)
    end

    begin
      Event.log(event_params)

      json_response({ message: 'Event log successfully' }, :created)
    rescue StandardError
      json_response({ message: 'Event log successfully' }, :unprocessable_entity)
    end
  end

  private

  def event_params
    params.require(:event).permit(:name, :type)
  end
end

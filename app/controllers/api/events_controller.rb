class Api::EventsController < ApplicationController
  # returns counters
  def index
    json_response({ events: LocalCounterStore.events })
  end

  def create
    unless RateLimiter.increment
      return json_response({
                             message: 'Event log failed',
                             error: { message: 'Slowdown! You are out of limit', cooldown: "#{RateLimiter.cooldown} seconds" }
                           }, :unprocessable_entity)
    end
    Event.log(event_params)

    json_response({ message: 'Event log successfully' }, :created)
  end

  private

  def event_params
    params.require(:event).permit(:key, :type)
  end
end

require 'rails_helper'

RSpec.describe 'Events API', type: :request do
  context 'Test Mock Sync' do
    let!(:valid_attributes) { { event: { name: 'music', type: 'clicks' } } }

    # reset rate limiting and empty redis counter
    before do
      RateLimiter.reset
      RedisCounterStore.delete_all
      post '/api/events', params: valid_attributes
      CountersService.sync
    end

    it 'redis has ' do
      key = "#{valid_attributes[:event][:name]}:#{DateUtil.time_key}"
      result = RedisCounterStore.query(key)
      expect(result).to_not be_empty
    end
  end
end

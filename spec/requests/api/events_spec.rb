require 'rails_helper'

RSpec.describe 'Events API', type: :request do
  let!(:valid_attributes) { { event: { name: 'music', type: 'clicks' } } }

  describe 'GET api/events' do
    before { get '/api/events' }

    it 'returns empty result' do
      expect(json['events']).to be_empty
    end
  end

  describe 'POST /api/events' do
    before { RateLimiter.reset }

    context 'when the request is valid' do
      before { post '/api/events', params: valid_attributes }

      it 'creates a event' do
        expect(json['message']).to eq('Event log successfully')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/api/events', params: { event: { type: 'clicks' } } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'creates a event' do
        expect(json.keys).to contain_exactly('error')
      end
    end
  end

  describe 'POST, Rate Limiting /api/events' do
    let!(:valid_attributes) { { event: { name: 'music', type: 'clicks' } } }

    context 'when the request is valid' do
      before { post '/api/events', params: valid_attributes }

      it 'creates a event' do
        expect(json['message']).to eq('Event log successfully')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { RateLimiter.reset }
      11.times do
        before { post '/api/events', params: valid_attributes }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'creates a event fails due to rate limiting' do
        expect(json.keys).to contain_exactly('error', 'message')
        expect(json['error'].keys).to contain_exactly('cooldown', 'message')
      end
    end
  end
end

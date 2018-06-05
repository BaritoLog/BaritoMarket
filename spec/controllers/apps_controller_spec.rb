require 'rails_helper'

RSpec.describe AppsController, type: :request do
  describe 'GET#index' do
    let(:apps) { create_list :barito_app, 3 }
    before(:each) { get '/apps' }

    it 'return appropriate response' do
      expect(response.status).to eq 200
    end

    it 'generate expected response' do
      expect(response.body).to match /#{apps.map(&:name).join('|')}/
    end
  end
end

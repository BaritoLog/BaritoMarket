require 'rails_helper'

RSpec.describe AppsController, type: :request do
  describe 'GET#index' do
    let(:barito_apps) { create_list(:barito_app, 3) }
    before(:each) { get '/apps' }

    it 'return appropriate response' do
      get apps_path
      expect(response.status).to eq 200
    end

    it 'generate expected response' do
      apps_list = barito_apps
      get apps_path
      expect(response.body).to match /#{apps_list.map(&:name).join('|')}/
    end
  end

  describe 'GET#new' do
    before(:each) { get new_app_path }

    it 'return appropriate response' do
      expect(response.status).to eq 200
    end

    it 'generate expected response' do
      expect(response.body).to match /Please enter the name of your application \/ service/
    end
  end
end

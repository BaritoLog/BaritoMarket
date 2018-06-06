require 'rails_helper'

RSpec.describe 'Apps management', type: :request do
  describe 'GET#index' do
    it 'should return appropriate response' do
      barito_apps = create_list(:barito_app, 3)
      get apps_path
      expect(response.body).to match /#{barito_apps.map(&:name).join('|')}/
    end

    it 'should return 200' do
      get apps_path
      expect(response.status).to eq 200
    end
  end

  describe 'GET#new' do
    before(:each) { get new_app_path }
    it 'should return appropriate response' do
      expect(response.body).to match /Please enter the name of your application \/ service/
    end

    it 'should return 200' do
      expect(response.status).to eq 200
    end
  end

  describe 'POST#create' do
    let(:new_barito_app) { build(:barito_app) }
    it 'should create new app in database' do
      expect {
        post apps_path, params: { barito_app: new_barito_app.attributes }
      }.to change { BaritoApp.count }.by(1)
    end

    it 'should return 302' do
      post apps_path, params: { barito_app: new_barito_app.attributes }
      expect(response.status).to eq 302
    end

    it 'should return appropriate response' do
      skip('Pending')
      # post apps_path, params: { barito_app: new_barito_app.attributes }
      # barito_app = BaritoApp.order(updated_at: :desc).first
      # expect(response.body).to match /#{barito_app.name}/
    end

    context "when incoming params is not appropriate" do
      it 'should have appropriate error message' do
        skip('Pending')
      end
    end
  end
end

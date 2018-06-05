require 'rails_helper'

RSpec.describe AppsController, type: :controller do
  describe 'GET#index' do
    let(:apps) { create_list :barito_app, 3 }
    before(:each) { get :index }

    it 'return appropriate response' do
      expect(response.status).to eq 200
    end

    it 'render apps/index.slim' do
      expect(response).to render_template(:index)
    end

    it 'assigns @apps' do
      expect(assigns(:apps)).to eq apps
    end
  end

end

require 'rails_helper'

RSpec.describe Api::AppController, type: :controller do
  describe 'GET#profile' do
    it 'return approriate response' do
      app = create(:barito_app)
      get :profile, params: { token: app.secret_key }, format: :json
      expected_response = app.attributes

      %w(id secret_key created_at updated_at log_count setup_status).each do |key|
        expected_response.delete(key)
      end
      json_response = JSON.parse(response.body)
      json_response.delete('updated_at')
      expect(json_response).to eq expected_response
    end
  end
end

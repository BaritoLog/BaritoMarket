require 'rails_helper'

RSpec.describe Traceable, type: :controller do
  let(:user) { create(:user) }

  controller(ApplicationController) do
    include Traceable

    # noinspection RubyResolve
    around_action :traced

    def index
      render json: {}, status: :ok
    end

    def error
      raise ApplicationController::NotAuthorizedError
    end

    def trace_prefix
      'foobar'
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'error' => 'anonymous#error'
    end
  end

  before :each do
    set_check_user_groups('groups' => ['barito-superadmin'])
    sign_in user
  end

  describe '#traced' do
    context 'with success execution' do
      it 'should be able to record an OpenTracing span' do
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with failure execution' do
      it 'should be able to record an OpenTracing span' do
        get :error
        expect(response).to have_http_status(:found)
      end
    end
  end
end

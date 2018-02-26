require 'test_helper'

class ServiceConfigsControllerTest < ActionController::TestCase
  setup do
    @service_config = service_configs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:service_configs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service_config" do
    assert_difference('ServiceConfig.count') do
      post :create, service_config: { config_json: @service_config.config_json, ip_address: @service_config.ip_address }
    end

    assert_redirected_to service_config_path(assigns(:service_config))
  end

  test "should show service_config" do
    get :show, id: @service_config
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service_config
    assert_response :success
  end

  test "should update service_config" do
    patch :update, id: @service_config, service_config: { config_json: @service_config.config_json, ip_address: @service_config.ip_address }
    assert_redirected_to service_config_path(assigns(:service_config))
  end

  test "should destroy service_config" do
    assert_difference('ServiceConfig.count', -1) do
      delete :destroy, id: @service_config
    end

    assert_redirected_to service_configs_path
  end
end

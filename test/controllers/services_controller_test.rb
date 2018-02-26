require 'test_helper'

class ServicesControllerTest < ActionController::TestCase
  setup do
    @service = services(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:services)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create service" do
    assert_difference('Service.count') do
      post :create, service: { description: @service.description, group_id: @service.group_id, heartbeat_url: @service.heartbeat_url, kafka_topic: @service.kafka_topic, kafka_topic_partition: @service.kafka_topic_partition, kibana_host: @service.kibana_host, name: @service.name, produce_url: @service.produce_url, store_id: @service.store_id }
    end

    assert_redirected_to service_path(assigns(:service))
  end

  test "should show service" do
    get :show, id: @service
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @service
    assert_response :success
  end

  test "should update service" do
    patch :update, id: @service, service: { description: @service.description, group_id: @service.group_id, heartbeat_url: @service.heartbeat_url, kafka_topic: @service.kafka_topic, kafka_topic_partition: @service.kafka_topic_partition, kibana_host: @service.kibana_host, name: @service.name, produce_url: @service.produce_url, store_id: @service.store_id }
    assert_redirected_to service_path(assigns(:service))
  end

  test "should destroy service" do
    assert_difference('Service.count', -1) do
      delete :destroy, id: @service
    end

    assert_redirected_to services_path
  end
end

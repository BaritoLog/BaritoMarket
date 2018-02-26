require 'test_helper'

class ForwardersControllerTest < ActionController::TestCase
  setup do
    @forwarder = forwarders(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:forwarders)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create forwarder" do
    assert_difference('Forwarder.count') do
      post :create, forwarder: { heartbeat_url: @forwarder.heartbeat_url, host: @forwarder.host, kafka_broker_hosts: @forwarder.kafka_broker_hosts, kafka_topics: @forwarder.kafka_topics, logstore_group_id: @forwarder.logstore_group_id, name: @forwarder.name, store_id: @forwarder.store_id, zookeeper_hosts: @forwarder.zookeeper_hosts }
    end

    assert_redirected_to forwarder_path(assigns(:forwarder))
  end

  test "should show forwarder" do
    get :show, id: @forwarder
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @forwarder
    assert_response :success
  end

  test "should update forwarder" do
    patch :update, id: @forwarder, forwarder: { heartbeat_url: @forwarder.heartbeat_url, host: @forwarder.host, kafka_broker_hosts: @forwarder.kafka_broker_hosts, kafka_topics: @forwarder.kafka_topics, logstore_group_id: @forwarder.logstore_group_id, name: @forwarder.name, store_id: @forwarder.store_id, zookeeper_hosts: @forwarder.zookeeper_hosts }
    assert_redirected_to forwarder_path(assigns(:forwarder))
  end

  test "should destroy forwarder" do
    assert_difference('Forwarder.count', -1) do
      delete :destroy, id: @forwarder
    end

    assert_redirected_to forwarders_path
  end
end

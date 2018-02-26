require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  setup do
    @group = groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count') do
      post :create, group: { id: @group.id, kafka_broker_hosts: @group.kafka_broker_hosts, kafka_manager_host: @group.kafka_manager_host, name: @group.name, receiver_heartbeat_url: @group.receiver_heartbeat_url, receiver_host: @group.receiver_host, zookeeper_hosts: @group.zookeeper_hosts }
    end

    assert_redirected_to group_path(assigns(:group))
  end

  test "should show group" do
    get :show, id: @group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @group
    assert_response :success
  end

  test "should update group" do
    patch :update, id: @group, group: { id: @group.id, kafka_broker_hosts: @group.kafka_broker_hosts, kafka_manager_host: @group.kafka_manager_host, name: @group.name, receiver_heartbeat_url: @group.receiver_heartbeat_url, receiver_host: @group.receiver_host, zookeeper_hosts: @group.zookeeper_hosts }
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete :destroy, id: @group
    end

    assert_redirected_to groups_path
  end
end

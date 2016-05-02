require 'test_helper'
module Api::V1
  class MedicationsControllerTest < ActionController::TestCase
    setup do
      @user = users(:one)
      @resource_user_id = users(:one).id
      @medication = medications(:one)
    end

    def init_owner
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end
    def init_doctor
      @user = users(:two)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end
    def init_stranger
      @user = users(:three)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should get index" do
      init_owner
      get :index, user_id: @resource_user_id
      assert_response :success
      result = JSON.parse(response.body)
      assert_equal 2, result.size
      assert_equal '3', result[0]['name']
      assert_equal 'insulin', result[0]['category']
      assert_equal '1', result[1]['name']
      assert_equal 'oral', result[1]['category']
    end

    test "stranger should not get index" do
      init_stranger
      get :index, user_id: @resource_user_id
      assert_response 403
    end

    test "doctor should not get index" do
      init_doctor
      get :index, user_id: @resource_user_id
      assert_response :success
    end

    test "should create medication" do
      init_owner
      assert_difference('Medication.count') do
        post :create, user_id: @resource_user_id, medication: {
                 source: 'testsource',
                 date: '2016-03-29 10:11:12',
                 name: '1'
                   }
      end
      result = JSON.parse(response.body)
      assert_response :success
    end

    test "owner should be able to delete medication" do
      init_owner
      assert_difference('Medication.count', -1) do
        delete :destroy, user_id: @resource_user_id, id: @medication.id
        assert_response :success
      end
    end

    test "stranger should not be able to delete diet" do
      init_stranger
      assert_difference('Diet.count', 0) do
        delete :destroy, user_id: @resource_user_id, id: @medication.id
        assert_response 403
      end
    end

    test "doctor should not be able to delete diet" do
      init_doctor
      assert_difference('Diet.count', 0) do
        delete :destroy, user_id: @resource_user_id, id: @medication.id
        assert_response 403
      end
    end

  end
end
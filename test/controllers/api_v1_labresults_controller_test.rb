require 'test_helper'
module Api::V1
  class LabresultsControllerTest < ActionController::TestCase

    setup do
      @labres = labresults(:one)
      @resource_user_id = users(:one).id
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

    test "owner should get index" do
      init_owner
      get :index, user_id: @resource_user_id
      assert_response :success
    end

    test "stranger should not get index" do
      init_stranger
      get :index, user_id: @resource_user_id
      assert_response 403
    end

    test "doctor should get index" do
      init_doctor
      get :index, user_id: @resource_user_id
      assert_response :success
    end

    test "owner should be able to delete labresult record" do
      init_owner
      assert_difference('Labresult.count', -1) do
        delete :destroy, user_id: @resource_user_id, id: @labres.id
        assert_response :success
      end
    end

    test "stranger should not be able to delete labresult record" do
      init_stranger
      assert_difference('Labresult.count', 0) do
        delete :destroy, user_id: @resource_user_id, id: @labres.id
        assert_response 403
      end
    end

    test "doctor should be able to delete labresult record" do
      init_doctor
      assert_difference('Labresult.count', -1) do
        delete :destroy, user_id: @resource_user_id, id: @labres.id
        assert_response :success
      end
    end

  end
end

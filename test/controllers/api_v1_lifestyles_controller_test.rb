require 'test_helper'
module Api::V1
  class LifestylesControllerTest < ActionController::TestCase

    setup do
      @lt1 = lifestyle_types(:ltone)
      @lt2= lifestyle_types(:lttwo)
      @lt = lifestyles(:one)
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
      json_result = JSON.parse(response.body)
      assert_equal 'paintype1', json_result[0]['name']
      assert_equal 'illnesstype1', json_result[1]['name']
    end

    test "stranger should not get index" do
      init_stranger
      get :index, user_id: @resource_user_id
      assert_response 403
    end

    test "owner should be able to create pain" do
      init_owner
      assert_difference('Lifestyle.count') do
        post :create, user_id: @resource_user_id, lifestyle: {
                        source: 'smartdiab',
                        name: @lt2.name,
                        start_time: Time.zone.now-3.days,
                        end_time: Time.zone.now-2.days,
                        amount: 1
                    }, format: :json
        assert_response :success
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
      end
    end

    test "owner should be able create illness" do
      init_owner
      assert_difference('Lifestyle.count') do
        post :create, user_id: @resource_user_id, lifestyle: {
            source: 'smartdiab',
            name: @lt1.name,
            start_time: Time.zone.yesterday,
            end_time: Time.zone.now,
            details: "illness test",
            amount: 3
        }, format: :json
        assert_response :success
        json_result = JSON.parse(response.body)
        assert_not json_result["id"].nil?
        newLifestyle = Lifestyle.find_by_id(json_result['id'])
        assert_equal 'illness', newLifestyle.lifestyle_type.category
        assert_equal 'illnesstype1', newLifestyle.lifestyle_type.name
        assert_equal 3, newLifestyle.amount
      end
    end

    test "owner should be able to delete lifestyle record" do
      init_owner
      assert_difference('Lifestyle.count', -1) do
        delete :destroy, user_id: @resource_user_id, id: @lt.id
        assert_response :success
      end
    end

    test "stranger should not be able to delete lifestyle record" do
      init_stranger
      assert_difference('Lifestyle.count', 0) do
        delete :destroy, user_id: @resource_user_id, id: @lt.id
        assert_response 403
      end
    end

    test "doctor should not be able to delete lifestyle record" do
      init_doctor
      assert_difference('Lifestyle.count', 0) do
        delete :destroy, user_id: @resource_user_id, id: @lt.id
        assert_response 403
      end
    end

  end
  
end

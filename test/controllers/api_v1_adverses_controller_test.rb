require 'test_helper'
module Api::V1
  class AdversesControllerTest < ActionController::TestCase

    setup do
      @adverse = adverses(:one)
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
      assert_equal 2, json_result[1]['id']
    end

    test "doctor should get index" do
      init_owner
      get :index, user_id: @resource_user_id
      assert_response :success
      json_result = JSON.parse(response.body)
      assert_equal 2, json_result[1]['id']
    end

    test "stranger should NOT get index" do
      init_stranger
      get :index, user_id: @resource_user_id
      assert_response 403
    end

    test "owner should be able to create" do
      init_owner
      assert_difference('Adverse.count') do
        post :create, user_id: @resource_user_id, adverse: {
                        time: '2016-01-27 16:17:17',
                        effect_present: 'true',
                        effect_detail: 'bad pain'
                    }, format: :json
        json_result = JSON.parse(response.body)
        assert_response :success
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
        newadverse = Adverse.find_by_id(json_result['id'])
        assert_equal 'bad pain', newadverse.effect_detail
      end
    end
  end
end

require 'test_helper'
module Api::V1
  class DietsControllerTest < ActionController::TestCase

    setup do
      @diet = diets(:one)
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
      assert_equal 'water', json_result[0]['name']
      assert_equal 'breakfast', json_result[1]['name']
    end

    test "stranger should get error" do
      init_stranger
      get :index, user_id: @resource_user_id
      assert_response 403
    end

    test "doctor should get index" do
      init_doctor
      get :index, user_id: @resource_user_id
      assert_response :success
      json_result = JSON.parse(response.body)
      assert_equal 'water', json_result[0]['name']
      assert_equal 'breakfast', json_result[1]['name']
    end

    test "should create diet for owner" do
      init_owner
      assert_difference('Diet.count') do
        post :create, user_id: @resource_user_id, diet: {
                        source: 'testdata',
                        date: '2016-01-27 16:17:17',
                        name: 'breakfast'
                    }, format: :json
        assert_response :success
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
        newdiet = Diet.find_by_id(json_result['id'])
        assert_equal 'breakfast', newdiet.food_type.name
      end
    end

    test "should not create diet for stranger" do
      init_stranger
      assert_difference('Diet.count', 0) do
        post :create, user_id: @resource_user_id, diet: {
                        source: 'testdata',
                        date: '2016-01-27 16:17:17',
                        name: 'breakfast'
                    }, format: :json
        assert_response 403
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], false
      end
    end

    test "should not create diet for doctor" do
      init_doctor
      assert_difference('Diet.count', 0) do
        post :create, user_id: @resource_user_id, diet: {
                        source: 'testdata',
                        date: '2016-01-27 16:17:17',
                        name: 'breakfast'
                    }, format: :json
        assert_response 403
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], false
      end
    end

    test "should create quick calory" do
      init_owner
      assert_difference('Diet.count') do
        post :create, user_id: @resource_user_id, diet: {
                        source: 'testdata',
                        date: '2016-01-27 16:17:17',
                        name: 'calory',
                        calories: 37,
                        carbs: 176
                    }, format: :json
        json_result = JSON.parse(response.body)
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
        newdiet = Diet.find_by_id(json_result['id'])
        assert_equal 'calory', newdiet.food_type.name
        assert_equal 37, newdiet.calories
        assert_equal 176, newdiet.carbs
      end
    end

    test "owner should be able to delete diet" do
      init_owner
      assert_difference('Diet.count', -1) do
        delete :destroy, user_id: @resource_user_id, id: @diet.id
        assert_response :success
      end
    end

    test "stranger should not be able to delete diet" do
      init_stranger
      assert_difference('Diet.count', 0) do
        delete :destroy, user_id: @resource_user_id, id: @diet.id
        assert_response 403
      end
    end

    test "doctor should not be able to delete diet" do
      init_doctor
      assert_difference('Diet.count', 0) do
        delete :destroy, user_id: @resource_user_id, id: @diet.id
        assert_response 403
      end
    end
  end
  
end

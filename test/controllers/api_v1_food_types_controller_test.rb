require 'test_helper'
module Api::V1
  class FoodTypesControllerTest < ActionController::TestCase
    setup do
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should get index" do
      get :index
      assert_response :success
      result = JSON.parse(response.body)
      assert_equal 2, result.size
      assert_equal "Reggeli", result[0]['hu']
    end
  end
end

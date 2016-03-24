require 'test_helper'

class FoodTypesControllerTest < ActionController::TestCase
  setup do
    @ft = food_types(:ftone)
    @user = users(:one)
    login_user
  end

  test "show should get translations" do
    get :show, id: 1
    assert_response :success
    result = JSON.parse(response.body)
    assert_equal "breakfast", result['name']
    assert_equal "Reggeli", result['hu']
    assert_equal "Breakfast", result['en']
  end

  test "index should get all food types" do
    get :index
    assert_response :success
    result = JSON.parse(response.body)
    assert_equal 2, result.size
  end

end

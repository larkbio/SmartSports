require 'test_helper'

class GeneticsControllerTest < ActionController::TestCase
  setup do
    @genetics = genetics(:one)
    @user = users(:one)
    @genetics_type = genetics_types(:one)
    login_user
  end

  test "should get index" do
    get :index, user_id: @user
    assert_response :success, format: :json
    assert_not_nil assigns(:genetics)
  end

  test "should create genetics" do
    assert_difference('Genetic.count') do
      post :create, user_id: @user.id, genetics_type_id: @genetics_type.id ,genetics: {
          source: @genetics.source,
          diabetes: @genetics.diabetes,
          group: @genetics.group,
          note: @genetics.note
      }, format: :json
      json_result = JSON.parse(response.body)
      puts json_result
      assert_equal json_result["ok"], true
      assert_not json_result["id"].nil?
    end
  end
end

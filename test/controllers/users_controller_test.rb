require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    login_user
  end

  test "should get index if admin" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should NOT get index if NOT admin" do
    @user = users(:two)
    login_user
    get :index, format: :json
    assert_response 403
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: {
          email: "xxx@ab.cd",
          password: "abcd",
          password_confirmation: "abcd"
          }, format: :json
    end

    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user.id, user: {
        name: "newname",
        password: "pwx1",
        password_confirmation: "pwx1"
      }, format: :json
    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end

  test "should update user if pw len >= 4" do
    I18n.locale = 'en'
    patch :update, id: @user.id, user: {
                     name: "newname",
                     password: "pwx",
                     password_confirmation: "pwx"
                 }, format: :json
    json_result = JSON.parse(response.body)
    # logger.debug JSON.pretty_generate(json_result)
    assert_equal json_result["ok"], false
    assert_equal json_result["msg"][0], "Password must be at least 4 characters!"
  end

  test "should destroy user" do
    user2 = users(:two)
    assert_difference('User.count', -1) do
      delete :destroy, id: user2, format: :json
    end

    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end

  test "should accept doctor flag" do
    assert_difference('User.count', 1) do
      post :create, user: {
                      email: "xxx@ab.cd",
                      password: "abcd",
                      password_confirmation: "abcd",
                      doctor: true
                  }, format: :json
    end
    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
    new_user = User.find(json_result["id"])
    assert new_user.doctor?, "new user is doctor"
  end

  test "should reject doctor flag if not admin" do
    @user = users(:two)
    login_user
    assert_difference('User.count', 0) do
      post :create, user: {
                      email: "xxx@ab.cd",
                      password: "abcd",
                      password_confirmation: "abcd",
                      doctor: true
                  }, format: :json
    end
    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], false
  end

end

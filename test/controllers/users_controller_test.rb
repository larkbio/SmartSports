require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def init_user
    @user = users(:one)
    login_user
  end
  def init_admin
    @user = users(:four)
    login_user
  end

  test "should get index if admin" do
    init_admin
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should NOT get index if NOT admin" do
    init_user
    get :index, format: :json
    assert_response 403
  end

  test "should create user" do
    init_admin
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
    init_user
    get :show, id: @user
    assert_response :success
  end


  test "should update user name and password" do
    init_user
    patch :update, id: @user.id, user: {
        name: "newname",
        password: "pwx1",
        password_confirmation: "pwx1"
      }, format: :json
    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end

  test "should update web_token_ios" do
    init_user
    patch :update, id: @user.id, user: {
                     web_token_ios: "TOK",
                 }, format: :json
    json_result = JSON.parse(response.body)
    u = User.find_by_id(@user.id)
    assert_equal "TOK", u.web_token_ios
  end

  test "should update user if pw len >= 4" do
    init_user
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
    init_admin
    user2 = users(:two)
    assert_difference('User.count', -1) do
      delete :destroy, id: user2, format: :json
    end

    json_result = JSON.parse(response.body)
    assert_equal json_result["ok"], true
  end

  test "should accept doctor flag" do
    init_admin
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
    init_user

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

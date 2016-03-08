require 'test_helper'
# require 'JSON'

class CustomFormsControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
    @user_two = users(:two)
  end

  test "should get index" do
    login_user(user = @user, route = login_url)
    get(:index, {'user_id' => 1})
    assert_response :success
  end

  test "should create" do
    login_user(user = @user, route = login_url)
    assert_difference("CustomForm.count", 1) do
      post :create, custom_form: {form_name: 'fn1', form_tag: 'ft1', image_name: 'img1'}, user_id: 1
    end
    assert_response :success
  end

  # TODO: make this work
  # test "should not create for others" do
  #   login_user(user = @user_two, route = login_url)
  #   assert_no_difference("CustomForm.count") do
  #     post :create, custom_form: {form_name: 'fn1', form_tag: 'ft1', image_name: 'img1'}, user_id: 1
  #   end
  #   assert_response :fail
  # end

  test "should update order_index" do
    login_user(user = @user, route = login_url)
    cf = custom_forms(:one)

    put :update, user_id: 1, id: cf.id, custom_form: {order_index: 10}

    assert_response :success
    resp =  JSON.parse(@response.body)
    assert resp['ok']

    cfnew = CustomForm.find_by_id(cf.id)
    assert_equal 10, cfnew.order_index, "custom form, order index attribute changed"
  end

  test "should update custom_form_element_order" do
    login_user(user = @user, route = login_url)
    cf = custom_forms(:one)
    patch :update, user_id: 1, id: cf.id, custom_form_element_order: ""

    resp =  JSON.parse(response.body)
    assert_response :success
    assert_equal true, resp['ok']
    
  end

  test "should get destroy" do
    login_user(user = @user, route = login_url)
    cf = custom_forms(:one)
    assert_difference("CustomForm.count", -1) do
      delete :destroy, id: cf.id, user_id: cf.user_id
    end

    assert_response :success

  end

end

require 'test_helper'
module Api::V1
  class FaqsControllerTest < ActionController::TestCase

    setup do
    end

    def setupAdmin
      @one = faqs(:one)
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    def setupUser
      @one = faqs(:one)
      @user = users(:two)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "plain user should get index" do
      setupUser
      get :index
      assert_response :success
      json_result = JSON.parse(response.body)
      assert_equal 3, json_result.size
    end

    test "index shows items in sortcode order" do
      setupUser
      get :index, lang: 'en'
      assert_response :success
      json_result = JSON.parse(response.body)
      assert_equal 2, json_result.size
      assert_equal 3, json_result[0]['id']
      assert_equal 1, json_result[1]['id']
    end

    test "plain user can not create" do
      setupUser
      assert_difference('Faq.count', 0) do
        post :create, user_id: @user.id, faq: {
                 sortcode: 50,
                 title: 'testing',
                 detail: 'more testing',
                 lang: 'en'
                    }
        assert_response 403
      end
    end

    test "admin user can create" do
      setupAdmin
      assert_difference('Faq.count', 1) do
        post :create, user_id: @user.id, faq: {
                        sortcode: 50,
                        title: 'testing',
                        detail: 'more testing',
                        lang: 'en'
                    }
        assert_response :success
      end
    end


    test "plain user can not update" do
      setupUser
      put :update, user_id: @user.id, id: 1, faq: {
                      sortcode: 123,
                  }
      assert_response 403
      one = Faq.find_by_id(1)
      assert_equal 30, one.sortcode
    end

    test "admin user can update" do
      setupAdmin
      one = Faq.find_by_id(1)
      assert_equal 30, one.sortcode
      put :update, user_id: @user.id, id: 1, faq: {
                     sortcode: 123,
                 }
      assert_response :success
      one = Faq.find_by_id(1)
      assert_equal 123, one.sortcode
    end

    test "plain user can not delete" do
      setupUser
      assert_difference('Faq.count', 0) do
        delete :destroy, user_id: @user.id, id: 1
        assert_response 403
      end
    end

    test "admin user can delete" do
      setupAdmin
      assert_difference('Faq.count', -1) do
        delete :destroy, user_id: @user.id, id: 1
        assert_response :success
      end
    end

  end

end

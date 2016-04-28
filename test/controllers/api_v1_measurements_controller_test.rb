require 'test_helper'
module Api::V1
  class MeasurementsControllerTest < ActionController::TestCase
    setup do
      @meas = measurements(:one)
      @user = users(:one)
      token = mock()
      token.expects(:acceptable?).at_least_once.returns(true)
      token.stubs(:resource_owner_id).returns(@user.id)
      @controller.stubs(:doorkeeper_token).returns(token)
    end

    test "should get index" do
      get :index, user_id: @user.id
      assert_response :success
      json_result = JSON.parse(response.body)
      assert_equal 4, json_result[0]['pulse']
      assert_equal 7, json_result[1]['pulse']
    end

    test "should create measurement" do
      assert_difference('Measurement.count') do
        post :create, user_id: @user.id, measurement: {
          source: 'testdata',
          date: '2016-01-27 16:17:17',
          diastolicbp: 11,
          systolicbp: 22,
          pulse: 33,
          SPO2: 44}, format: :json
        json_result = JSON.parse(response.body)
        puts json_result
        assert_equal json_result["ok"], true
        assert_not json_result["id"].nil?
      end
    end
  end
end

require 'test_helper'

class PredictControllerTest < ActionController::TestCase
  test "should get predict_by_pcode" do
    get :predict_by_pcode
    assert_response :success
  end

  test "should get predict_by_LatLon" do
    get :predict_by_LatLon
    assert_response :success
  end

end

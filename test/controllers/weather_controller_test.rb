require 'test_helper'

class WeatherControllerTest < ActionController::TestCase
  test "should get data_by_pcode" do
    get :data_by_pcode
    assert_response :success
  end

  test "should get data_by_loc" do
    get :data_by_loc
    assert_response :success
  end

  test "should get predict_by_pcode" do
    get :predict_by_pcode
    assert_response :success
  end

  test "should get predict_by_LatLon" do
    get :predict_by_LatLon
    assert_response :success
  end

end

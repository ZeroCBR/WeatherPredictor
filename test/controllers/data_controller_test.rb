require 'test_helper'

class DataControllerTest < ActionController::TestCase
  test "should get data_by_pcode" do
    get :data_by_pcode
    assert_response :success
  end

  test "should get data_by_loc" do
    get :data_by_loc
    assert_response :success
  end

end

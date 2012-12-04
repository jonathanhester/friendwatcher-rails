require 'test_helper'

class FacebookControllerTest < ActionController::TestCase
  test "should get rtu" do
    get :rtu
    assert_response :success
  end

end

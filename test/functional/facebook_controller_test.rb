require 'test_helper'

class FacebookControllerTest < ActionController::TestCase
  test "should get rtu" do
    get :rtu, { "hub.mode" => 1 }
    assert_response :success
  end

end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should say token valid" do
    user = users(:one)
    response = get :verify_token, {id: user.fbid, token: user.token}
    assert_equal "1", response.body, "response should be 1"
   end

  test "should say token invalid" do
    user = users(:one)
    user.update_attribute(:token_invalid, true)
    response = get :verify_token, {id: user.fbid, token: user.token}
    assert_equal "0", response.body, "response should be 0"
  end

end

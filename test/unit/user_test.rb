require 'test_helper'

class UserTest < ActiveSupport::TestCase

  FRIENDS_WILL = {
      "name" => "Will Chen",
      "id" => "194"
  }
  FRIENDS_ALTAY = {
      "name" => "Altay Guvench",
      "id" => "4345"
  }

  test "verify valid user" do
    user = users(:one)
    assert_not_nil User.verify(user.fbid, user.token)
    assert_nil User.verify(user.fbid, "")
  end

  test "verify invalid user" do
    assert_nil User.verify("asdfasdfasdf", "")
  end

  test "validates valid user" do
    user = users(:one)
    User.any_instance.stubs(:reload_friends)
    User.stubs(:fetch_user).returns({id: "doesn't matter"})
    found_user = User.validate_user user.fbid, user.token
    assert found_user
  end

  test "validates valid user - token changed" do
    user = users(:one)
    User.any_instance.stubs(:reload_friends)
    User.stubs(:fetch_user).returns({id: "doesn't matter"})
    found_user = User.validate_user user.fbid, "newtoken"
    assert found_user
    assert_equal "newtoken", found_user.token
  end

  test "doesn't validate user" do
    User.stubs(:fetch_user).raises
    found_user = User.validate_user "garbage", "newtoken"
    assert_blank found_user
  end


  test "reload friends - first time" do
    user = users(:no_friends)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL, FRIENDS_ALTAY])
    user.reload_friends
    assert_equal 2, user.friends.current.count
    assert_equal 2, user.friends.count
  end


  test "reload friends - no changes" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL, FRIENDS_ALTAY])
    user.reload_friends
    assert_equal 2, user.friends.current.count
    assert_equal 2, user.friends.count
  end

  test "reload friends - dropped Altay" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL])
    User.stubs(:fetch_user).returns(FRIENDS_ALTAY)
    user.reload_friends
    assert_equal 1, user.friends.current.count
    assert_equal 1, user.friends.removed.count
    assert_equal 2, user.friends.count
    assert_equal "4345", user.friends.removed.first.fbid
  end

  test "reload friends - Altay hid profile" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL])
    User.stubs(:fetch_user).raises
    user.reload_friends
    assert_equal 1, user.friends.current.count, "should have 1 current"
    assert_equal 0, user.friends.removed.count, "should have 0 removed"
    assert_equal 1, user.friends.disabled.count, "should have 1 disabled"
    assert_equal 2, user.friends.count, "should have 2 total"
    assert_equal "4345", user.friends.disabled.first.fbid
  end

  test "reload friends - Altay unhides profile" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL, FRIENDS_ALTAY])
    User.stubs(:fetch_user).returns({})
    user.friends.where(fbid: 4345).first.update_attribute(:status, :disabled)
    user.reload_friends
    assert_equal 2, user.friends.current.count, "should have 2 current"
    assert_equal 0, user.friends.disabled.count, "should have 0 disabled"
    assert_equal 2, user.friends.count, "should have 2 total"
  end

end

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  fbid               :string(255)
#  token              :string(255)
#  token_invalid_date :datetime
#  token_invalid      :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  last_synced        :datetime
#

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
  FRIENDS_BOGLE = {
      "name" => "Brian Bogle",
      "id" => "757084104"
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

  test "reload friends - first time" do
    user = users(:no_friends)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL, FRIENDS_ALTAY])
    user.reload_friends(true)
    assert_equal 2, user.friends.current.count
    assert_equal 2, user.friends.count
    assert_equal 0, user.friend_events.count
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


  test "reload friends - added 2" do
    user = users(:no_friends)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL, FRIENDS_ALTAY])
    user.reload_friends
    assert_equal 2, user.friends.current.count
    assert_equal 2, user.friends.count
    assert_equal 2, user.friend_events.added.count
  end

  test "reload friends - no changes" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL, FRIENDS_ALTAY])
    user.reload_friends
    assert_equal 2, user.friends.current.count
    assert_equal 1, user.friend_events.removed.count
  end

  test "reload friends - dropped Altay" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL])
    User.stubs(:fetch_user).returns(FRIENDS_ALTAY)
    user.reload_friends
    assert_equal 1, user.friends.current.count
    assert_equal 2, user.friend_events.removed.count
    assert_equal 1, user.friends.count
    assert user.friend_events.removed.map(&:fbid).include?("4345")
  end

  test "reload friends - added bogle back" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL, FRIENDS_ALTAY, FRIENDS_BOGLE])
    User.stubs(:fetch_user).returns(FRIENDS_ALTAY)
    (added, removed) = user.reload_friends_without_delay
    assert_equal 1, added.count
    assert_equal 3, user.friends.current.count
    assert_equal 1, user.friend_events.removed.count
    assert_equal 3, user.friends.count
    assert_equal "757084104", user.friend_events.removed.first.fbid
  end

  test "reload friends - Altay hid profile" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([FRIENDS_WILL])
    User.stubs(:fetch_user).raises
    user.reload_friends
    assert_equal 1, user.friends.current.count, "should have 1 current"
    assert_equal 1, user.friend_events.removed.count, "should have 1 removed"
    assert_equal 1, user.friends.disabled.count, "should have 1 disabled"
    assert_equal 2, user.friends.count, "should have 3 total"
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
    assert_equal 2, user.friends.count, "should have 3 total"
  end

  test "receives update and sends success gcm" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([])
    GcmMessager.expects(:friends_changed).returns(true)
    user.receive_update
  end

  test "receives update and sends error gcm" do
    user = users(:one)
    user.stubs(:fetch_friends).raises(Koala::Facebook::APIError)
    GcmMessager.expects(:invalid_token).returns(true)
    user.receive_update
  end

  test "reload friends sets token_invalid on error" do
    user = users(:one)
    user.stubs(:fetch_friends).raises(Koala::Facebook::APIError)
    assert_raise Koala::Facebook::APIError do
      user.reload_friends
      assert_equal true, user.token_invalid, "should mark token invalid"
    end
  end

  test "force refresh and sends success GCM" do
    user = users(:one)
    user.stubs(:fetch_friends).returns([])
    GcmMessager.expects(:force_refresh).returns(true)
    user.force_refresh

  end

  test "force refresh and sends error GCM" do
    user = users(:one)
    user.stubs(:fetch_friends).raises(Koala::Facebook::APIError)
    GcmMessager.expects(:invalid_token).returns(true)
    user.force_refresh
  end

end

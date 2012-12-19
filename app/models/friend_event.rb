# == Schema Information
#
# Table name: friend_events
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  fbid       :string(255)
#  name       :string(255)
#  event      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FriendEvent < ActiveRecord::Base
  belongs_to :user

  scope :removed, where(event: :removed)
  scope :added, where(event: :added)
end

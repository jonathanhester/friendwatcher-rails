# == Schema Information
#
# Table name: friends
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  fbid                 :integer
#  name                 :string(255)
#  status_modified_date :datetime
#  status               :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Friend < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :fbid, :scope => :user_id

  scope :current, where(status: :current)
  scope :removed, where(status: :removed)
  scope :disabled, where(status: :disabled)
end

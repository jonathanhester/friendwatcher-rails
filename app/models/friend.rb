# == Schema Information
#
# Table name: friends
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  fbid                 :string(255)
#  name                 :string(255)
#  status_modified_date :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  status               :string(255)
#

class Friend < ActiveRecord::Base
  belongs_to :user

  scope :current, where(status: :current)
  scope :disabled, where(status: :disabled)
end

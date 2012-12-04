# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  device_id       :string(255)
#  registration_id :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Device < ActiveRecord::Base
  belongs_to :user

  validates :device_id, presence: true
  validates :registration_id, presence: true
end

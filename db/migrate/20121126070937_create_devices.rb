class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :user
      t.string :device_id
      t.string :registration_id
      t.timestamps
    end
  end
end

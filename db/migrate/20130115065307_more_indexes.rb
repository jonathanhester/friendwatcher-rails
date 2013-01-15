class MoreIndexes < ActiveRecord::Migration
  def up
    add_index :devices, :user_id
    add_index :friend_events, :user_id
  end

  def down
  end
end

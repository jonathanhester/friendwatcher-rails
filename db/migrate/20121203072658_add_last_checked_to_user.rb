class AddLastCheckedToUser < ActiveRecord::Migration
  def up
    add_column :users, :last_synced, :datetime
  end

  def down
    remove_column :users, :last_synced
  end
end

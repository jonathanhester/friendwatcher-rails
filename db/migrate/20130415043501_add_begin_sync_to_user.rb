class AddBeginSyncToUser < ActiveRecord::Migration
  def change
    add_column :users, :begin_sync, :datetime
  end
end

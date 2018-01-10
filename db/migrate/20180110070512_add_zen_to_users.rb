class AddZenToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :total_completed_zen_levels, :integer
    add_column :users, :continuous_zen_levels, :integer
  end
end

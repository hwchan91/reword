class AddDefaultZenSolvedForUser < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :total_completed_zen_levels, :integer, :default => 0
    change_column :users, :continuous_zen_levels, :integer, :default => 0
  end
end

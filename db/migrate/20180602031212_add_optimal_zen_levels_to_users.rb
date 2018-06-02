class AddOptimalZenLevelsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :optimal_zen_levels, :integer, default: 0
  end
end

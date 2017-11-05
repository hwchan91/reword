class AddLimitToLevels < ActiveRecord::Migration[5.1]
  def change
    add_column :levels, :limit, :integer
  end
end

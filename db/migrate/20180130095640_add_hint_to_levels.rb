class AddHintToLevels < ActiveRecord::Migration[5.1]
  def change
    add_column :levels, :hint, :integer, array: true, default: []
  end
end

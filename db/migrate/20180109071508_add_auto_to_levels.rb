class AddAutoToLevels < ActiveRecord::Migration[5.1]
  def change
    add_column :levels, :auto, :boolean, default: false
    add_column :levels, :daily, :boolean, default: false
  end
end

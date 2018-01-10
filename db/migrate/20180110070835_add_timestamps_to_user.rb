class AddTimestampsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :levels, :created_at, :datetime
    add_column :levels, :updated_at, :datetime
  end
end

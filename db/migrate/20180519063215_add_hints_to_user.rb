class AddHintsToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :hints, :jsonb, default: {}
  end
end

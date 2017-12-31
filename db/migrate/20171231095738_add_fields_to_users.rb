class AddFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :completed_levels, :text, array: true, default: []
    add_column :users, :optimal_levels, :text, array: true, default: []
    add_column :users, :name, :string
    add_column :users, :password_digest, :string
  end
end

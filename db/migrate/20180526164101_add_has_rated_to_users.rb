class AddHasRatedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :has_rated, :boolean, default: :false
  end
end

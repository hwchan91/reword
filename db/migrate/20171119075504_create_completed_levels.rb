class CreateCompletedLevels < ActiveRecord::Migration[5.1]
  def change
    create_table :completed_levels do |t|
      t.integer :level_id
      t.text :best_path, array: true, default: []
      t.boolean :optimal_achieved, default: false
      t.integer :user_id

      t.timestamps
    end
  end
end

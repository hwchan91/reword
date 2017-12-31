class RemoveCompletedLevels < ActiveRecord::Migration[5.1]
  def change
    drop_table :completed_levels do |t|
      t.integer "level_id"
      t.text "best_path", default: [], array: true
      t.boolean "optimal_achieved", default: false
      t.integer "user_id"

      t.timestamps
    end
  end
end
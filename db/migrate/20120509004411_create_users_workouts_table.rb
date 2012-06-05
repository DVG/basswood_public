class CreateUsersWorkoutsTable < ActiveRecord::Migration
  def up
    create_table :users_workouts, :id => false do |t|
      t.references :user, :workout
    end

    add_index :users_workouts, [:user_id, :workout_id]
  end

  def down
    drop_table :users_workouts
  end
end

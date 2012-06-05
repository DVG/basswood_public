class AddTrainerIdToWorkout < ActiveRecord::Migration
  def change
    add_column :workouts, :trainer_id, :integer

  end
end

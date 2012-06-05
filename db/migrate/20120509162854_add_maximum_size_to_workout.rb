class AddMaximumSizeToWorkout < ActiveRecord::Migration
  def change
    add_column :workouts, :maximum_size, :integer

  end
end

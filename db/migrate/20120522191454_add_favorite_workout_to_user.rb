class AddFavoriteWorkoutToUser < ActiveRecord::Migration
  def change
    add_column :users, :favorite_workout, :string

  end
end

class AddHideMeToUser < ActiveRecord::Migration
  def change
    add_column :users, :hide_me, :boolean

  end
end

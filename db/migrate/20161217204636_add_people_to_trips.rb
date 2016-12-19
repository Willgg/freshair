class AddPeopleToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :people, :integer
  end
end

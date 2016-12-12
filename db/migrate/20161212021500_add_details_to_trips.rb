class AddDetailsToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :duration, :float
    add_column :trips, :departure_date, :date
    add_reference :trips, :airport, index: true, foreign_key: true
  end
end

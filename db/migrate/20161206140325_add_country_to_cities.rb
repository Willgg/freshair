class AddCountryToCities < ActiveRecord::Migration
  def change
    add_column :cities, :country, :string
  end
end

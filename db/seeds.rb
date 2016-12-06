# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'
require 'open-uri'

def fetch_origin
  url = 'https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat'
  CSV.new(open(url)).each do |line|
    if line[3] == 'France'
      unless City.where(name: line[2]).exists?
        city = City.new(name: line[2], country: line[3])
        city.save
      else
        city = City.where(name: line[2]).first
      end
      airport = Airport.new(name: line[1], iata: line[4], icao: line[5])
      airport.city = city
      airport.save
    end
  end
end

Airport.destroy_all
City.destroy_all
fetch_origin

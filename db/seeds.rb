# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv'
require 'open-uri'

def list_amadeus_airports(*currencies)
  puts "START PARSING CSV..."
  url = 'https://raw.githubusercontent.com/amadeus-travel-innovation-sandbox/sandbox-content/master/flight-search-cache-origin-destination.csv'
  airports = []
  CSV.new(open(url)).each do |row|
    if currencies.include?(row[0])
      airports << row[1] unless airports.include?(row[1])
      airports << row[2] unless airports.include?(row[2])
    end
  end
  puts '################## Amadeus airports ##################'
  puts airports.inspect
  return airports
end

def create_airports(authorized_airports)
  url = 'https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat'
  CSV.new(open(url)).each do |line|
    if authorized_airports.include?(line[4])
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

authorized_airports = list_amadeus_airports('EUR', 'GBP')
create_airports(authorized_airports)

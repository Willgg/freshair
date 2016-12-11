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
    if currencies.any? && currencies.include?(row[0])
      airports << row[1] unless airports.include?(row[1])
      airports << row[2] unless airports.include?(row[2])
    elsif currencies.empty?
      airports << row[1]
      airports << row[2]
    end
  end
  airports.uniq!
  puts airports.inspect
  return airports
end

def create_airports(airports)
  url = 'https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat'
  list = CSV.new(open(url)).to_a
  missing = []
  airports.each do |airport|
    line = list.select { |row| row[4] == airport}
    line = line.flatten
    if line.empty?
      missing << airport
    else
      city = City.find_by(name: line[2])
      if city.nil?
        city = City.new(name: line[2], country: line[3])
        puts city.errors.messages unless city.save
      end
      airport = Airport.new(name: line[1], iata: line[4], icao: line[5])
      airport.city = city
      puts airport.errors.messages unless airport.save
    end
  end
  puts "AIRPORTS MISSING IN DATABASE: " + missing.inspect
end

create_airports(list_amadeus_airports('EUR', 'GBP', 'CSK'))

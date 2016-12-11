require 'json'
require 'csv'
require 'open-uri'

class AmadeusService
  include ServicesHelper

  attr_accessor :origin, :destination, :departure_date, :one_way, :duration, :direct, :max_price, :aggregation_mode

  def initialize(origin, options = {})
    @apikey = ENV['AMADEUS_KEY']
    @origin = origin
    @destination = options[:destination]
    @departure_date = options[:departure_date]
    @one_way = options[:one_way]
    @duration = options[:duration]
    @direct = options[:direct]
    @max_price = options[:max_price]
    @aggregation_mode = options[:aggregation_mode]
  end

  def get_inspiration(*options)
    url = 'https://api.sandbox.amadeus.com/v1.2/flights/inspiration-search'
    uri = url + '?' + 'apikey=' + @apikey + '&' + 'origin=' + @origin
    uri = uri + '&' + 'departure_date=' + @departure_date unless @departure_date.blank?
    uri = uri + '&' + 'direct=' + @direct.to_s unless @direct.blank?
    uri = uri + '&' + 'destination=' + @destination unless @destination.blank?
    uri = uri + '&' + 'duration=' + @duration.to_s unless @duration.blank?
    result = open(uri).read
    result_json = JSON.parse(result)
    return result_json
  end

  def get_low_fare(options = {})
    missing = [:destination, :departure_date] - options.keys
    raise "#{missing.join(", ")} are missing" if missing.size > 1
    raise "#{missing.join(", ")} is missing" if missing.size <= 1
    url = 'https://api.sandbox.amadeus.com/v1.2/flights/low-fare-search'
    uri = url + '?' + 'apikey=' + @apikey + '&' + 'origiœn=' + @origin
    uri = uri + '&' + 'destination=' + @destination + 'departure_date=' + @departure_date
    uri = uri + '&' + 'direct=' + @direct.to_s unless @direct.blank?
    uri = uri + '&' + 'duration=' + @duration.to_s unless @duration.blank?
    result = open(uri).read
    result_json = JSON.parse(result)
    return result_json
  end

  def list_currencies
    currencies = []
    url = AmadeusService.url_supported_flights
    CSV.new(open(url)).each do |row|
      unless currencies.include?(row[0])
        currencies << row[0]
      end
    end
    return currencies
  end

  def list_origins(*currencies)
    data = {}
    url = AmadeusService.url_supported_flights
    CSV.new(open(url)).each do |row|
      if currencies.any? && currencies.include?(row[0])
        data[row[0]] = [] unless data.key?(row[0])
        data[row[0]] << row[1] unless data[row[0]].include?(row[1])
      elsif currencies.empty?
        data[row[0]] = [] unless data.key?(row[0])
        data[row[0]] << row[1] unless data[row[0]].include?(row[1])
      end
    end
    return data
  end

  def list_origins_destinations(*currencies)
    data = {}
    url = AmadeusService.url_supported_flights
    CSV.new(open(url)).each do |row|
      data[row[0]] = {} unless data.key?(row[0])
      unless data[row[0]].key?(row[1])
        data[row[0]][row[1]] = []
      else
        data[row[0]][row[1]] << row[2]
      end
    end
    data = filter_by_currencies(data, currencies) unless currencies.empty?
    return data
  end

  def self.list_destinations(*currencies)
    destinations = []
    url = AmadeusService.url_supported_flights
    CSV.new(open(url)).each do |row|
      if currencies.any? && currencies.include?(row[0])
        destinations << row[2]
      elsif currencies.empty?
        destinations << row[2]
      end
    end
    return destinations.uniq
  end

  # TODO: move this method into job and add airbnb scrapping result to
  def build_trips(currencies)
    # TODO these variables must be put in app config
    departure_dates = [date_of_next('Friday').to_s, date_of_next('Saturday').to_s]
    duration = [2, 3]
    nb_people_list = (2..3)
    airbnb = {}
    # TODO: Call one job per airport so if scrapping fails that will be scheduled for later
    list_origins(currencies).values.flatten.each do |origin|
      trips = {}
      departure_dates.each do |date|

        trips[date] = {}
        airbnb[date] = {} if airbnb[date].nil?

        duration.each do |duration|

          # Fetch Flights from Amadeus
          flights = AmadeusService.new(origin, departure_date: date, duration: duration, direct: true).get_inspiration
          # Add Amadeus flights to Trips
          unless !flights['status'].nil? && flights['status'] == '400'
            trips[date][duration] = flights
          end
          # List the destinations to scrap with Airbnb
          destinations = []
          flights['results'].each do |flight|
            destinations << flight['destination'] unless destinations.include?(flight['destination'])
          end

          # Scrap every destinations on Airbnb
          airbnb[date][duration] = {} if airbnb[date][duration].nil?

          destinations.each do |destination|
            airbnb[date][duration][destination] = {} if airbnb[date][duration][destination].nil?
            nb_people_list.each do |people|
              checkin  = date.to_date
              checkout = date.to_date + (duration.days)
              begin
                price = (AirbnbScrapping.new(destination, checkin, checkout, people).scrap_price) / people
                price = price.round(2)
              rescue
                price = ''
              end
              sleep 6
              airbnb[date][duration][destination][people] = price
              puts airbnb
            end
          end

        end
      end
      puts trips
      puts airbnb
      # $redis.set(origin, trips.to_json)
      puts "############### End of origin case ##############"
    end
  end

  private

  def filter_by_currencies(data, currencies)
    selection = {}
    currencies.each do |cur|
      part = data.select { |k, v| k == cur }
      selection.merge!(part)
    end
    return selection
  end

  def self.url_supported_flights
    'https://raw.githubusercontent.com/amadeus-travel-innovation-sandbox/sandbox-content/master/flight-search-cache-origin-destination.csv'
  end
end

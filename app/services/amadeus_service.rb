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

    puts uri
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

  def self.list_origins(*currencies)
    currencies.flatten!
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
  def build_trips(*currencies)
    departure_dates = [Scraper::date_of_next('Friday').to_s, Scraper::date_of_next('Saturday').to_s]
    duration = Scraper::DURATIONS
    airbnb   = JSON.parse($redis.get('airbnb'))

    AmadeusService.list_origins(currencies).values.flatten.each do |origin|
      trips = {}
      departure_dates.each do |date|
        trips[date] = {}

        duration.each do |duration|
          flights = AmadeusService.new(origin, departure_date: date, duration: duration, direct: true).get_inspiration
          unless !flights['status'].nil? && flights['status'] == '400'

            # Keep only destinations included in Airbnb Scraping
            flights['results'].reject! { |flight| airbnb[flight['destination']].nil? }

            # Add Airbnb price to every destination
            flights['results'].each do |flight|
              destination = flight['destination']
              if airbnb[destination]
                flight['airbnb'] = airbnb[destination][flight['departure_date']][duration.to_s]
              end
            end

            trips[date][duration] = flights
          end
        end
      end
      $redis.set(origin, trips.to_json)
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

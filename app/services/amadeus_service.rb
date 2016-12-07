require 'json'
require 'csv'
require 'open-uri'

class AmadeusService

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
    uri = url + '?' + 'apikey=' + @apikey + '&' + 'origin=' + @origin
    uri = uri + '&' + 'destination=' + @destination + 'departure_date=' + @departure_date
    uri = uri + '&' + 'direct=' + @direct.to_s unless @direct.blank?
    uri = uri + '&' + 'duration=' + @duration.to_s unless @duration.blank?
    result = open(uri).read
    result_json = JSON.parse(result)
    return result_json
  end

  def self.list_supported_origins(*currencies)
    data = {}
    url = 'https://raw.githubusercontent.com/amadeus-travel-innovation-sandbox/sandbox-content/master/flight-search-cache-origin-destination.csv'
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

  # TODO: move this method into job and add airbnb scrapping result to
  def self.build_city_flights(currencies)
    departure_dates = [date_of_next('Friday').to_s, date_of_next('Saturday').to_s]
    duration = [2, 3]
    list_supported_origins(currencies).values.flatten.each do |airport|
      city_flights = {}
      departure_dates.each do |date|
        city_flights[date] = {}
        duration.each do |duration|
          results = AmadeusService.new(airport, departure_date: date, duration: duration, direct: true).get_inspiration
          unless !results['status'].nil? && results['status'] == '400'
            city_flights[date][duration] = results
          end
        end
      end
      $redis.set(airport, city_flights.to_json)
    end
  end

  private

  def self.date_of_next(day)
    date  = Date.parse(day)
    delta = date > Date.current ? 0 : 7
    date + delta
  end

end

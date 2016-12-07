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
    uri = url + '?' + 'apikey=' + @apikey + '&' + 'origin=' + @origin
    uri = uri + '&' + 'destination=' + @destination + 'departure_date=' + @departure_date
    uri = uri + '&' + 'direct=' + @direct.to_s unless @direct.blank?
    uri = uri + '&' + 'duration=' + @duration.to_s unless @duration.blank?
    result = open(uri).read
    result_json = JSON.parse(result)
    return result_json
  end

  def list_origins(*currencies)
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
  def build_trips(currencies)
    # TODO these variables must be put in app config
    departure_dates = [date_of_next('Friday').to_s, date_of_next('Saturday').to_s]
    duration = [2, 3]
    nb_people_list = (2..4)
    # TODO: Call one job per airport so if scrapping fails that will be scheduled for later
    list_origins(currencies).values.flatten.each do |airport|
      trips = {}
      departure_dates.each do |date|
        trips[date] = {}
        duration.each do |duration|
          # Add Amadeus result from API
          results = AmadeusService.new(airport, departure_date: date, duration: duration, direct: true).get_inspiration
          results.each do |result|
            # Add Airbnb price for each destination (redondant)
            # ou Airbnb pour chaque destination au global et on va chercher dedans après
          end

          unless !results['status'].nil? && results['status'] == '400'
            trips[date][duration] = { amadeus: results }
          end
          # Add Airbnb result from scrapping
          # trips[date][duration][:airbnb] = {}
          # nb_people_list.each do |people|
          #   checkin  = date.to_date
          #   checkout = date.to_date + (duration.days)
          #   begin
          #     price = AirbnbScrapping.new(airport, checkin, checkout, people).scrap_price
          #   rescue
          #     price = ''
          #   end
          #   sleep 5
          #   trips[date][duration][:airbnb][people] = { average_price: price }
          # end
        end
      end
      $redis.set(airport, trips.to_json)
      puts "##################################"
    end
  end

end

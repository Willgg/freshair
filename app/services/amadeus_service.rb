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

  def get_inspiration(options)
    missing = options.keys - [:apikey, :origin]
    raise "#{missing.join(", ")} are missing" if missing.size > 1
    raise "#{missing.join(", ")} is missing" if missing.size > 0
    url = 'https://api.sandbox.amadeus.com/v1.2/flights/inspiration-search'
    uri = url + '?' + 'apikey=' + @apikey + '&' + 'origin=' + @origin
  end

  def get_low_fare(options)
    missing = options.keys - [:apikey, :origin, :destination, :departure_date]
    raise "#{missing.join(", ")} are missing" if missing.size > 1
    raise "#{missing.join(", ")} is missing" if missing.size <= 1
    url = 'https://api.sandbox.amadeus.com/v1.2/flights/low-fare-search'
    uri = url + '?' + 'apikey=' + @apikey + '&' + 'origin=' + @origin
    uri = uri + '&' + 'destination=' + @destination + 'departure_date=' + @departure_date
  end
end

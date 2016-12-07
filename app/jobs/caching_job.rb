class CachingJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    departure_dates = [date_of_next('Friday').to_s, date_of_next('Saturday').to_s]
    duration = [2, 3]
    currencies = ['EUR', 'GBP']
    AmadeusService.list_supported_origins(currencies).values.flatten.each do |airport|
      puts airport
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
      puts city_flights
      puts "#######################"
      # $redis.set(airport, city_flights.to_json)
    end
  end

  private

  def date_of_next(day)
    date  = Date.parse(day)
    delta = date > Date.current ? 0 : 7
    date + delta
  end
end

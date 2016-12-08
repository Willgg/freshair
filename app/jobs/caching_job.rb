class CachingJob < ActiveJob::Base
  include ServicesHelper

  queue_as :default

  def perform(*args)
    departure_dates = [date_of_next('Friday').to_s, date_of_next('Saturday').to_s]
    duration = [2, 3]
    currencies = ['EUR', 'GBP']
    AmadeusService.list_origins(currencies).values.flatten.each do |airport|
      city_flights = {}
      departure_dates.each do |date|
        city_flights[date] = {}
        duration.each do |duration|
          results = AmadeusService.new(airport, departure_date: date, duration: duration, direct: true).get_inspiration
          unless !results['status'].nil? && results['status'] == '400'
            city_flights[date][duration] = { amadeus: results }
          end
        end
      end
      $redis.set(airport, city_flights.to_json)
    end
  end

end

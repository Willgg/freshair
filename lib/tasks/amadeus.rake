namespace :amadeus do
  desc "TODO"
  task cache: :environment do
    departure_dates = [Scraper::date_of_next('Friday').to_s, Scraper::date_of_next('Saturday').to_s]
    duration = Scraper::DURATIONS
    currencies = Scraper::CURRENCIES
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

end

namespace :amadeus do
  extend Scraper
  desc "Todo"
  task cache_all: :environment do
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
                airbnb_prices = airbnb[destination][flight['departure_date']][duration.to_s]
                # Convert Airbnb prices to flights currency
                airbnb_prices.each do |people, price|
                  airbnb_prices[people] = Currency.new('EUR', flights['currency'], price).convert if flights['currency'] != 'EUR'
                  puts price.to_s + '  ' + airbnb_prices[people].to_s
                end
                flight['airbnb'] = airbnb_prices
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

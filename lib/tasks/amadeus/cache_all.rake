namespace :amadeus do
  desc "Store data in cache from Amadeus API's inspiration endpoint"
  task cache_all: :environment do
    dates      = Scraper::dates
    duration   = Scraper::DURATIONS
    currencies = Scraper::CURRENCIES
    airbnb     = JSON.parse($redis.get('airbnb'))

    AmadeusService.list_origins(currencies).values.flatten.each do |origin|
      trips = {}
      dates.each do |date|
        trips[date] = {}

        duration.each do |duration|
          begin
            flights = AmadeusService.new(origin, departure_date: date, duration: duration, direct: true).get_inspiration

            # Keep only destinations included in Airbnb Scraping
            flights['results'].reject! { |flight| airbnb[flight['destination']].nil? }

            # Add Airbnb price to every destination
            flights['results'].each do |flight|
              destination = flight['destination']
              if airbnb[destination]
                airbnb_prices = airbnb[destination][flight['departure_date']][duration.to_s]

                # Convert Airbnb prices to flights currency
                airbnb_prices.each do |people, price|
                  airbnb_prices[people] =
                    Currency::Fixer.new('EUR', flights['currency'], price).convert_from_cache if flights['currency'] != 'EUR'
                end
                flight['airbnb'] = airbnb_prices
              end
            end

            trips[date][duration] = flights
          rescue
          end
        end
      end
      $redis.set(origin, trips.to_json)
    end
  end

end

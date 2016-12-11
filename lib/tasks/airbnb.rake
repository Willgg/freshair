namespace :airbnb do
  desc "Scrap Airbnb for all destinations supported by Amadeus and store it in redis cache"
  task cache_all: :environment do
    destinations = AmadeusService.list_destinations('AED')
    dates = [Scraper::date_of_next('Friday').to_s, Scraper::date_of_next('Friday').to_s]
    durations = Scraper::DURATIONS
    adults_range = Scraper::PEOPLE
    puts "START AIRBNB SCRAPING ..."
    # Cache::AirbnbJob.perform_later(destinations, dates, durations, adults_range)

    dates = dates.map { |date| date.to_date }
    results = {}
    destinations.each do |destination|
      results[destination] = {} if results[destination].nil?

      dates.each do |date|
        results[destination][date] = {} if results[destination][date].nil?
        durations.each do |duration|
          results[destination][date][duration] = {} if results[destination][date][duration].nil?

          adults_range.each do |adults|
            checkin  = date
            checkout = checkin + duration.days
            request = AirbnbScrapping.new(destination, checkin, checkout, adults)
            price   = request.scrap_price
            price_person = (price / adults).round(2)
            results[destination][date][duration][adults] = price_person
            puts results
            sleep (5..10).sample
          end
        end
      end
    end
    $redis.set('airbnb', results)
  end
end

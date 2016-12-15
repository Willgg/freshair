namespace :airbnb do
  desc "Scrap Airbnb for all destinations supported by Amadeus"
  task cache_all: :environment do
    destinations = Scraper::european_airports
    dates = [Scraper::date_of_next('Friday').to_s, Scraper::date_of_next('Saturday').to_s]
    durations = Scraper::DURATIONS
    adults_range = Scraper::PEOPLE
    puts "#####################################"
    puts "START AIRBNB SCRAPING ..."
    puts "DESTINATIONS: #{destinations.inspect}"
    puts "DATES: #{dates.inspect}"
    puts "DURATIONS: #{durations.inspect}"
    puts "PEOPLE: #{adults_range.inspect}"
    puts "#####################################"

    dates = dates.map { |date| date.to_date }
    results = {}
    count = 0
    destinations.each do |destination|
      results[destination] = {} if results[destination].nil?

      dates.each do |date|
        results[destination][date] = {} if results[destination][date].nil?
        durations.each do |duration|
          results[destination][date][duration] = {} if results[destination][date][duration].nil?

          adults_range.each do |adults|
            checkin  = date
            checkout = checkin + duration.days
            request = AirbnbScrapping.new(destination, checkin, checkout , adults)
            puts ''
            puts '*** Request for ' + destination.to_s + ', checkin: ' + checkin.to_s + ', checkout:' + checkout.to_s + ', ' + adults.to_s + ' adults people ***'
            price   = request.scrap_price
            price_person = (price / adults).round(2)
            results[destination][date][duration][adults] = price_person
            sleep [4, 6, 7, 8].sample
          end
        end
      end
      count += 1
      puts (destinations.count - count).to_s + ' remaining destinations'
      puts ''
    end
    results = results.to_json
    $redis.set('airbnb', results)
  end
end

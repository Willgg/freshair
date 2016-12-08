namespace :airbnb do
  desc "Scrap Airbnb for all destinations supported by Amadeus and store it in redis cache"
  task cache_all: :environment do
    destinations = AmadeusService.list_destinations('EUR')
    dates = [Scraper::date_of_next('Friday'), Scraper::date_of_next('Friday')]
    durations = Scraper::DURATIONS
    adults_range = Scraper::PEOPLE
    puts "START AIRBNB SCRAPING ..."
    Cache::AirbnbJob.perfom_later(destinations, dates, durations, adults_range)
  end
end

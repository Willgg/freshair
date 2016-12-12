namespace :amadeus do
  desc "Clear redis cache for every supported origin airport"
  task clear_all: :environment do
    Scraper::european_airports.each { |airport| $redis.del(airport) }
  end
end

namespace :flight do
  desc "Store in cache all flights details for every Cities white-listed by Amadeus"
  task caching_all: :environment do
    puts "Fetching all flights information..."
    # for each airport present in Amadeus white list
    # FlightScrapperJob.perform
  end

end

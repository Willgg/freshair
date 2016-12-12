namespace :airbnb do
  desc "Clear the cache of Airbnb prices"
  task clear_all: :environment do
    $redis.del('airbnb')
  end
end

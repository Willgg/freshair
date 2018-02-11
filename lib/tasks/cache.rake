namespace :cache do
  desc "Scrap and add all services to redis cache"
  task all: :environment do
    Rake::Task["currency:fixer:cache"].invoke
    Rake::Task["currency:layer:cache"].invoke
    Rake::Task['amadeus:cache_all'].invoke
    Rake::Task['airbnb:cache_all'].invoke
  end
end

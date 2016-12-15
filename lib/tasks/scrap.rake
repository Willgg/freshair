namespace :cache do
  desc "Scrap Airbnb for all destinations supported by Amadeus"
  task reset: :environment do
    Rake::Task["currency:fixer:clear"].invoke
    Rake::Task["currency:fixer:cache"].invoke
    Rake::Task["currency:fixer:clear"].invoke
    Rake::Task["currency:layer:cache"].invoke
    Rake::Task["airbnb:clear_all"].invoke
    Rake::Task['airbnb:cache_all'].invoke
    Rake::Task["amadeus:clear_all"].invoke
    Rake::Task['amadeus:cache_all'].invoke
  end
end

namespace :weather do
  namespace :openweather do
    desc "Cache OpenWeather's forecast"
    task cache: :environment do
      puts "Start fetching data with OpenWeather..."
      timer = Time.now
      Weather::OpenWeather.cache(Scraper.european_airports)
      timer = (Time.now - timer).round(2)
      puts "Fetching data with OpenWeather done in #{timer}s."
    end
  end
end

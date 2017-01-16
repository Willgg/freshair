namespace :weather do
  namespace :apixu do
    desc "Cache APIXU's weather forecast"
    task cache: :environment do
      puts "Start fetching Weather with Apixu..."
      timer = Time.now
      client  = Apixu::Client.new ENV['APIXU_KEY']
      weather = $redis.get('weather') ? JSON.parse($redis.get('weather')) : Hash.new
      new_dates = []
      Scraper.dates.first(2).each do |date|
        Scraper::DURATIONS.each { |x| new_dates << date + x.days }
      end
      dates = (new_dates | Scraper.dates.first(2)).sort
      Scraper.european_airports.each do |k|
        city = Airport.find_by(iata: k).city
        forecast = client.forecast(city.name, 10)
        weather[k] = {} if weather[k].nil?
        dates.each do |date|
          strfdate = date.strftime('%Y-%m-%d')
          fc_days = forecast['forecast']['forecastday']
          fc_date = fc_days.select { |day| day['date'] == strfdate }.first
          weather[k][strfdate] = fc_date['day'].slice('avgtemp_c', 'condition') unless fc_date.nil?
        end
      end
      $redis.set('weather', weather.to_json)
      timer = (Time.now - timer).round(2)
      puts "Fetching Weather with Apixu done in #{timer}s."
    end
  end
end

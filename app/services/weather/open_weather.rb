module Weather

  class OpenWeather
    attr_reader :city, :forecast

    def initialize(city)
      @city = city
    end

    def fetch_forecast(options={ mode: :json, units: :metric, cnt: 16})
      url = "http://api.openweathermap.org/data/2.5/forecast/daily?q=#{@city}"
      url += "&mode=#{options[:mode].to_s}" if options[:mode]
      url += "&units=#{options[:units].to_s}" if options[:units]
      url += "&cnt=#{options[:cnt].to_s}" if options[:cnt]
      url += "&APPID=#{key}"
      openweather_serialized = open(url).read
      @forecast = JSON.parse(openweather_serialized)
    end

    def self.filtered_forecast(start_date, end_date, cities=nil)
      data = cities.empty? ? get_cache : only_for(cities)
      data.each_pair do |city, dates|
        dates.keep_if { |date, temp| (start_date..end_date).include? Date.parse(date) }
      end
    end

    def self.only_for(cities)
      get_cache.select { |k, v| cities.include?(k) }
    end

    def self.get_cache
      JSON.parse($redis.get('weather'))
    end

    def self.set_cache(airports)
      weather = Hash.new
      airports.each do |k|
        city = Airport.find_by(iata: k).city
        forecast = self.new(city.name).fetch_forecast
        fc_dates = forecast['list'].select { |day| dates.include?( Time.at(day['dt']).to_date ) }
        weather[k] = Hash.new
        fc_dates.each do |datapoint|
          strfdate = Time.at(datapoint['dt']).to_date.strftime('%Y-%m-%d')
          weather[k][strfdate] = datapoint.slice('temp', 'weather')
        end
      end
      $redis.set('weather', weather.to_json)
    end

    private

    def key
      ENV['OPENWEATHER_KEY']
    end

    def self.dates
      new_dates = []
      Scraper.dates.each do |date|
        Scraper::DURATIONS.each { |x| new_dates << date + x.days }
      end
      (new_dates + Scraper.dates).sort
    end
  end

end

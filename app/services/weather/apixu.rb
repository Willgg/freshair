module Weather

  class Apixu
    attr_reader :forecast

    def initialize(data)
      @forecast = data
    end

    def only_for(cities)
      @forecast.select { |k, v| cities.include?(k) }
    end

    def filter_forecast(cities, start_date, end_date)
      only_for(cities).each_pair do |city, dates|
        dates.keep_if { |date, temps| (start_date..end_date).include? Date.parse(date) }
      end
    end

    def avg_min_max_temp(cities, start_date, end_date)
      sum_min, sum_max, count = 0, 0, 0
      minified = Hash.new
      dataset = filter_forecast(cities, start_date, end_date)
      dataset.each_pair do |city, dates|
        dates.each_pair do |date, value|
          sum_min += value['mintemp_c']
          sum_max += value['maxtemp_c']
          count += 1
        end
        minified[city] = { 'mintemp_c': (sum_min / count).round(1),
                           'maxtemp_c': (sum_max / count).round(1) }
      end
      return minified
    end
  end

end

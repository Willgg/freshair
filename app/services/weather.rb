class Weather

  attr_reader :temperatures

  def initialize(data)
    @temperatures = data
  end

  def sort_by_temperature
    @temperatures.sort_by { |_k, v| (v.values.reduce(:+) / v.values.size) }
  end

  def only_for(cities)
    @temperatures.select { |k, v| cities.include?(k) }
  end

  def avg_temperature(cities, start_date, end_date)
    sum = 0
    count = 0
    new_h = Hash.new
    only_for(cities).each_pair do |city, data|
      data.each_pair do |date, value|
        unless Date.parse(date) < start_date || Date.parse(date) > end_date
          sum += value['avgtemp_c']
          count += 1
        end
      end
      new_h[city] = (sum / count).round(1)
    end
    return new_h
  end
end

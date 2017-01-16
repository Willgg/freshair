class Weather

  attr_reader :temperatures

  def initialize(data)
    @temperatures = data
  end

  def sort_by_temperature
    @temperatures.sort_by { |_k, v| (v.values.reduce(:+) / v.values.size) }
  end
end

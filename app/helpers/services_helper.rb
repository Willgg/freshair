module ServicesHelper
  def date_of_next(day)
    date  = Date.parse(day)
    delta = date > Date.current ? 0 : 7
    date + delta
  end

  def convert_currencies(from, to, amount)
    url = "http://api.fixer.io/latest?symbols=#{from},#{to}"
    conversion_serialized = open(url).read
    conversion = JSON.parse(conversion_serialized)
    if conversion["base"] == to
      amount * (1/conversion["rates"][from])
    elsif conversion["base"] == from
      amount * conversion["rates"][to]
    end
  end
end

class Currency

  attr_accessor :from, :to, :amount
  attr_reader :url

  def initialize(from, to, amount)
    @from = from
    @to = to
    @amount = amount
  end

  def convert
    answer = open(build_url).read
    rates  = JSON.parse(answer)
    rate   = (1 / rates['quotes']['USD' + @from]) * rates['quotes']['USD' + @to]
    amount = @amount * rate
  end

  def build_url
    url = "http://apilayer.net/api/live?access_key=" + ENV['CURRENCYLAYER_KEY']
    url += "&currencies=#{@from},#{@to}"
  end
end

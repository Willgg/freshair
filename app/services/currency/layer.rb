module Currency

  class Layer < Base

    def initialize(from, to, amount)
      super(from, to, amount)
    end

    def convert_from_api
      rates  = get_parsed_rates
      rate   = (1 / rates['quotes']['USD' + @from]) * rates['quotes']['USD' + @to]
      amount = @amount * rate
    end

    def normalize(hash)
      ref = 1 / hash['quotes']["USDEUR"]
      a = hash['quotes'].map do |key, value|
            key != "USDEUR" ? [key.delete('USD'), (value * ref)] : ["USD", 1 / value]
          end
      rates = { 'base' => 'EUR', 'rates' => a.to_h }
    end

    def build_url
      url = "http://apilayer.net/api/live?access_key=" + ENV['CURRENCYLAYER_KEY']
      url += "&currencies=#{@from},#{@to}"
    end

    def self.real_time_url
      url = "http://apilayer.net/api/live?access_key=" + ENV['CURRENCYLAYER_KEY']
      url = url + "&currencies=" + Scraper::CURRENCIES.join(',')
    end

  end

end

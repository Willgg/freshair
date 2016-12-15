module Currency

  class Base
    attr_accessor :from, :to, :amount
    attr_reader :url

    def initialize(from, to, amount)
      @from = from
      @to = to
      @amount = amount
    end

    def get_parsed_rates
      answer  = open(build_url, 'User-Agent' => Scraper::user_agents.sample).read
      JSON.parse(answer)
    end

    def convert_from_cache
      return @amount if @from == @to
      hash = normalize(self.class.rates_from_cache)
      rates = hash['rates']
      case hash['base']
        when @to
          @amount * (1 / rates[@from])
        when @from
          @amount * rates[@to]
        else
          @amount * ( ( 1 / rates[@from] ) * rates[@to] )
      end
    end

    def self.rates_from_cache
      rates = $redis.get(self.to_s)
      JSON.parse(rates)
    end

    def self.rates_from_api
      #TODO: define in argument the method to call in #open
      answer  = open(real_time_url, 'User-Agent' => Scraper::user_agents.sample).read
      JSON.parse(answer)
    end

    def self.cache
      response = $redis.set(self.to_s, self.rates_from_api.to_json)
      return true if response == "OK"
    end

    def self.clear_cache
      response = $redis.del(self.to_s)
      return true if response > 0
    end
  end

end

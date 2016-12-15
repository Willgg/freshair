module Currency

  class Fixer < Base

    def initialize(from, to, amount)
      super(from, to, amount)
    end

    def convert_from_api
      result  = get_parsed_rates
      rates   = result['rates']
      return @amount if @from == @to
      case result['base']
        when @to
          @amount * (1 / rates[@from])
        when @from
          @amount * rates[@to]
        else
          @amount * ( ( 1 / rates[@from] ) * rates[@to] )
      end
    end

    def normalize(hash)
      hash.select {|k,v| (k == 'base' || k == 'rates')}
    end

    def build_url
      'http://api.fixer.io/latest?symbols=' + @from + @to
    end

    def self.real_time_url
      "http://api.fixer.io/latest"
    end

  end

end

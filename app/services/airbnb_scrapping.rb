require 'open-uri'
require 'open_uri_redirections'
require 'nokogiri'

class AirbnbScrapping
  include ServicesHelper

  attr_accessor :city, :checkin_date, :checkout_date, :adults, :entire_home

  def initialize(iata, checkin, checkout, nb_adults, entire_home=true)
    @city = Airport.where(iata: iata).first.city
    @checkin_date = checkin
    @checkout_date = checkout
    @adults = nb_adults
    @entire_home = entire_home
    @url = 'https://www.airbnb.fr/s/'
  end

  def scrap_price
    uri = @url + clean(@city.name) + '--' + clean(@city.country)
    uri = uri + '?' + 'adults=' + @adults.to_s
    uri = uri + '&' + 'checkin=' + CGI.escape(@checkin_date.strftime('%d/%m/%Y'))
    uri = uri + '&' + 'checkout=' + CGI.escape(@checkout_date.strftime('%d/%m/%Y'))
    uri = uri + '&room_types%5B%5D=Entire%20home%2Fapt' if @entire_home
    puts 'URL: ' + uri

    prices = []
    while prices.blank?
      html_file = open(uri, 'User-Agent' => Scraper::user_agents.sample)
      html_doc = Nokogiri::HTML(html_file)
      html_doc.search('span[data-pricerate]').each do |element|
        prices << element.text.slice(/[^\W]+/).to_f.round(2)
      end
      avg_price = prices.inject(0, :+) / prices.length
      puts '* Prices scraped: ' + avg_price.inspect
    end
    puts '* Price to convert =>' + avg_price.to_s + ' USD'
    converted_price = Currency::Fixer.new('USD', 'EUR', avg_price).convert_from_cache
    puts '* Price converted =>' + converted_price.round(4).to_s + ' EUR'
    return converted_price.round(4)
  end

  private

  def clean(name)
    name = name.gsub(/\s/, '-')
    name = name.gsub(/St./, 'Saint')
  end
end

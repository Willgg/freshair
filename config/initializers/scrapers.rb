module Scraper
  PEOPLE = (1..2)
  DURATION = (2..3)
  CURRENCIES = ['EUR', 'GBP']

  def date_of_next(day)
    date  = Date.parse(day)
    delta = date > Date.current ? 0 : 7
    date + delta
  end

end

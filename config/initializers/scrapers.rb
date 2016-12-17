module Scraper
  PEOPLE = [2, 3]
  DAYS = ['Friday', 'Saturday']
  DURATIONS = [1, 2]
  CURRENCIES = ['EUR', 'GBP']
  AIRPORTS = { 'AL' => ['TIA'],
      'DE' => ['TXL', 'DRS', 'FRA', 'HAM', 'MUC', 'STR', 'DUS', 'CGN'],
      'AM' => ['EVN'],
      'AT' => ['VIE'],
      'BE' => ['BRU'],
      'BG' => ['SOF'],
      'CY' => ['LCA'],
      'HR' => ['ZAG'],
      'DK' => ['CPH'],
      'ES' => ['SPC', 'TFN', 'LPA', 'ALC', 'IBZ', 'BCN', 'ACE', 'MAD', 'PMI', 'TFS', 'AGP'],
      'EE' => ['TLL'],
      'FI' => ['HEL'],
      'FR' => ['LYS', 'MRS', 'NCE', 'PAR'],
      'GR' => ['ATH', 'SKG'],
      'HU' => ['BUD'],
      'IE' => ['DUB'],
      'IS' => ['KEF'],
      'IT' => ['BLQ', 'LIN', 'MXP', 'NAP', 'PSA', 'FCO', 'VCE'],
      'LV' => ['RIX'],
      'LT' => ['VNO'],
      'MK' => ['SKP'],
      'PT' => ['FCN', 'JFY', 'FAO', 'OPO'],
      'MT' => ['MLA'],
      'NO' => ['OSL', 'SVG'],
      'NL' => ['AMS', 'RTM'],
      'PL' => ['WAW'],
      'RO' => ['OTP'],
      'GB' => ['LON', 'ABZ', 'EDI', 'INV', 'BFS', 'BHD', 'BHX', 'GLA', 'LBA', 'MAN', 'NCL', 'EMA'],
      'RU' => ['SVO', 'LED'],
      'CZ' => ['PRG'],
      'RS' => ['BEG'],
      'SK' => ['BTS'],
      'SI' => ['LJU'],
      'CH' => ['ACH', 'ZRH', 'GVA'],
      'SE' => ['GOT', 'ARN'],
      'UA' => ['IEV', 'KBP']
    }

  def self.dates
    DAYS.map do |day|
      date  = Date.parse(day)
      delta = date > Date.current ? 0 : 7
      date += delta
      day = [date, date + 7.days]
    end.flatten.sort
  end

  def self.user_agents
    app          = 'freshairbot'
    open         = 'OpenData/1.0'
    chrome_linux = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36'
    ie           = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko'
    ff_linux     = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0'
    return [app, chrome_linux, ie, ff_linux]
  end

  def self.european_airports
    #TODO: currencies are statics !
    AIRPORTS.values.flatten & AmadeusService.list_destinations(CURRENCIES[0], CURRENCIES[1], CURRENCIES[2])
  end
end

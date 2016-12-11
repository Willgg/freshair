class Cache::AirbnbJob < ActiveJob::Base
  queue_as :default

  def perform(destinations, dates, durations, adults_range)
    dates = dates.map { |date| date.to_date }
    results = {}
    destinations.each do |destination|
      results[destination] = {} if results[destination].nil?

      dates.each do |date|
        results[destination][date] = {} if results[destination][date].nil?

        durations.each do |duration|
          results[destination][date][duration] = {} if results[destination][date][duration].nil?

          adults_range.each do |adults|
            checkin  = date
            checkout = checkin + duration.days
            begin
              price    = AirbnbScrapping.new(destination, checkin, checkout, adults).scrap_price
              price_person = (price / adults).round(2)
            rescue
              price = ''
            end
            results[destination][date][duration][adults] = price_person
          end
        end
      end
    end
    $redis.set('airbnb', results)
  end

end

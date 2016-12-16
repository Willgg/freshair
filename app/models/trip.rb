class Trip < ActiveRecord::Base
  belongs_to :airport

  validates :duration, presence: true
  validates :departure_date, presence: true

  def self.find_cheapest(options)
    date     = options[:departure_date]
    origin   = options[:origin]
    duration = options[:duration]
    people   = options[:people]

    results  = JSON.parse($redis.get(origin))
    results  = results[date][duration]['results']
    results  = results.sort {|a, b| a["price"].to_i + a["airbnb"][people].to_i <=> b["price"].to_i + b["airbnb"][people].to_i}
  end
end

class Trip < ActiveRecord::Base
  belongs_to :airport

  validates :duration, presence: true
  validates :departure_date, presence: true
end

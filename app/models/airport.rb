class Airport < ActiveRecord::Base
  belongs_to :city
  has_one :trip

  validates :name, presence: true
  validates :iata, presence: true, uniqueness: true
end

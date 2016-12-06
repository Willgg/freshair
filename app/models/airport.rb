class Airport < ActiveRecord::Base
  belongs_to :city

  validates :name, presence: true, uniqueness: true
  validates :iata, presence: true, uniqueness: true
end

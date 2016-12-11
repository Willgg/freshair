class City < ActiveRecord::Base
  has_many :airports, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end

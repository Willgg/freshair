class City < ActiveRecord::Base
  has_many :airports, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def clean_to_str
    city = name.gsub(/\s/, '-').gsub(/St\./, 'Saint')
    country = self.country.gsub(/\s/, '-').gsub(/St./, 'Saint')
    return city + '--' + country
  end
end

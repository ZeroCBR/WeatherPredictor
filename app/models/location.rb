class Location < ActiveRecord::Base
  has_many :measurements
  belongs_to :postcode
  validates :name, uniqueness: true

  def self.location_mapping(lat, long)
    self.where(latitude: lat, longitude: long)
  end

  def self.location_similar(lat, long)
    locations = self.all
    sum = 1296000000000.0
    id = 0
    locations.each do
    |location|
      distance = (location.latitude-lat)**2+(location.longitude-long)**2
      if distance < sum
        sum = distance
        id=location.id
      end
    end
    return id
  end


end

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
    puts('Similar')
    locations.each do
    |location|
      distance = (location.latitude.to_f-lat.to_f)**2+(location.longitude.to_f-long.to_f)**2
      if distance < sum
        sum = distance
        id=location.id
        puts("Similar:#{id}")
      end
    end
    return [Location.find(id)]
  end


end

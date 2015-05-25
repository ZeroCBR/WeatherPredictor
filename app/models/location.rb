class Location < ActiveRecord::Base
	has_many :measurements
	belongs_to :postcode
	validates :name, uniqueness: true

	def self.location_mapping(lat,long)
		self.where(latitude: lat, longitude: long)
	end

	def self.location_similar(lat,long)
		locations=self.all
		sum=1000.0
		id=0
		locations.each do |location|
			if (location.latitude-lat).abs+(location.longitude-long).abs<sum
				sum=(location.latitude-lat).abs+(location.longitude-long).abs
				id=location.id
			end
		end
		return id
	end


end

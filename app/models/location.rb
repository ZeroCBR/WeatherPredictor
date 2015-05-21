class Location < ActiveRecord::Base
	has_many :measurement
	belongs_to :postcode
	validates :name, uniqueness: true
end

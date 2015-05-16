class Location < ActiveRecord::Base
	has_many :measurements
	belongs_to :postcode
end

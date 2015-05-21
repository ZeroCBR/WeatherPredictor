class Postcode < ActiveRecord::Base
	has_many :location
end

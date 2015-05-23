class Postcode < ActiveRecord::Base
	has_many :locations
	validates :postcode, uniqueness: true
end

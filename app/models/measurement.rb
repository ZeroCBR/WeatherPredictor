class Measurement < ActiveRecord::Base
	belongs_to :location

	def self.get_history(id)
		
	end
end

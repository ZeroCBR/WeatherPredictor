class Measurement < ActiveRecord::Base
	belongs_to :location

	def self.get_history(id)
		self.where(location_id: id, time:(Time.now - 3.day)..Time.now)
	end
end

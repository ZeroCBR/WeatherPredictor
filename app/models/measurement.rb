class Measurement < ActiveRecord::Base
	belongs_to :location

	def self.get_history(id)
		
	end

	def self.get_data_by_loc(loctionId, time)
		self.where(location_id: loctionId, time: (time..(time + 1.day)))
	end

	def  self.get_data_in_30min(loctionId)
		self.where(location_id: loctionId, time: (Time.now..(Time.now + 1800)))
	end
end

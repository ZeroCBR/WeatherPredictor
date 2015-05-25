class DataController < ApplicationController
	def data_by_pcode
		
	end

	def data_by_loc
	end

	def listLocations
		@locations=Location.all
	end
end

class DataController < ApplicationController
	def data_by_pcode
		pcode = params[:postcode]
		date = params[:date]
		postcode = Postcode.find_by_postcode(pcode)
		# location = Location.find_by_postcode(pcode)
		render plain: {"date": date, "locations": postcode}.inspect
	end

	def data_by_loc
		loc_name = params[:location_id]
		date = params[:date]
		location = Location.find_by_name(loc_name)
		# location = Location.find_by_postcode(pcode)
		render plain: {"date": date, "locations": location}.inspect
	end

	def listLocations
		@locations = Location.all
		@postcode = Postcode.all
	end
end

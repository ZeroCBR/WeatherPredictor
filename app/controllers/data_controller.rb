class DataController < ApplicationController
	def data_by_pcode
		pcode = params[:post_code]
		date = params[:date]
		meas_jsons = {}
		measurements = []
		locations_needed = []
		

		postcode = Postcode.find_by_postcode(pcode)
		locations = Location.all
		measurements = Measurement.all
		measurements_needed = []

		date.match /(\d{2})-(\d{2})-(\d{4})/
		time = Time.new($3,$2,$1)

		locations.collect do |l|
			if l.postcode_id == postcode.id
				locations_needed.push(l)
			end
		end

		# measure_total = []
		# locations_needed.each do |l|
		# 	measure_each = Measurement.get_data_by_loc(l.id, time)
		# 	measure_total+= measure_each
		# end





		locations_info_all = locations_needed.collect do |l|
			measure_total = []
			measure_each = Measurement.get_data_by_loc(l.id, time)
			measure_total+= measure_each
			# measurements.collect do |m|
			# 	if m.location_id == l.id 
			# 		measurements_needed.push(m)
			# 	end
			# end

			meas_needed_all = measurements_needed.collect do |m|
				meas_needed_all = 
				{
					"time": m.time,
					"temp": m.temp,
					"precip": m.precip,
					"wind_direction": m.windDir,
					"wind_speed": m.windSpeed,
				}
			end

			location_info =
			{
				"id": l.name,
				"lat": l.latitude,
				"lon": l.longitude,
				"last_update": l.updated_at,
				"measurements": meas_needed_all
			}

		end
		
			
		output = {
				"date": date, 
				"locations": locations_info_all
					}.as_json
		

		render plain: Time.new(2015,02,2).inspect
	end

	def data_by_loc
		
	end

	def listLocations
		@locations = Location.all
		@postcode = Postcode.all
	end
end

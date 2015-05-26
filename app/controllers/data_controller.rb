require 'json'

require_relative '../../lib/extract_data'
require_relative '../../lib/formater'


class DataController < ApplicationController
	def data_by_pcode
		pcode = params[:post_code]
		date = params[:date]


		
		output = Extractor.by_pcode(pcode,date)

		render plain: output.inspect
	end


	def data_by_loc
		loc_name = params[:location_id]
		date = params[:date]
		location = Location.find_by_name(loc_name)
		loctionId = location.id
		# location = Location.find_by_postcode(pcode)

		date.match /(\d{2})-(\d{2})-(\d{4})/
		time = Time.new($3,$2,$1)

		Date.strptime(date)

		measurements_data = Measurement.get_data_by_loc(loctionId, time)

		measurement_now = Measurement.get_data_in_30min(loctionId)

		measure_latest = measurement_now[0]

		measurement_json=[]

		measurements_data.each do |measure|
			each_json = {
				"time" => measure.time,
				"temp" => measure.temp,
				"precip" => measure.precip,
				"wind_direction" => measure.windDir,
				"wind_speed" => measure.windSpeed 
			}

			measurement_json << each_json
		end


		if measure_latest == nil
			json_by_loc = {"date" => date, 
				"current_temp" => "",
				"current_cond" => "", 
				"measurements" => measurement_json
			}.as_json
		else
			json_by_loc = {"date" => date, 
				"current_temp" => measure_latest.temp,
				"current_cond" => measure_latest.condition, 
				"measurements" => measurement_json
			}.as_json
		end



		render plain: json_by_loc.inspect
	end

	def listLocations
		@locations = Location.all
	end
end

require_relative './formater'

class Extractor
	def self.by_pcode pcode, date
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
			# measurements.collect do |m|
			# 	if m.location_id == l.id 
			# 		measurements_needed.push(m)
			# 	end
			# end

			measure_total = measure_each.collect do |m|
				measure_total = 
				{
					"time"=> m.time,
					"temp"=> m.temp,
					"precip"=> m.precip,
					"wind_direction"=> Format.windDir(m.windDir),
					"wind_speed"=> m.windSpeed,
				}
			end

			location_info =
			{
				"id"=> l.name,
				"lat"=> l.latitude,
				"lon"=> l.longitude,
				"last_update"=> l.updated_at,
				"measurements"=> measure_total
			}

		end
		
			
		return {
				"date"=> date, 
				"locations"=> locations_info_all
					}.as_json
	end

	def self.data_by_loc_json loctionId, date

		date.match /(\d{2})-(\d{2})-(\d{4})/
		time = Time.new($3,$2,$1)

		measurements_data = Measurement.get_data_by_loc(loctionId, time)

		measurement_now = Measurement.get_data_in_30min(loctionId)

		measure_latest = measurement_now.last

		measurement_json=[]

		measurements_data.each do |measure|
			each_json = {
				'time' => measure.time,
				'temp' => measure.temp,
				'precip' => measure.precip,
				'wind_direction' => Format.windDir(measure.windDir),
				'wind_speed' => measure.windSpeed 
			}

			measurement_json << each_json
		end


		if measure_latest == nil
			json_by_loc = {'date' => date, 
				'current_temp' => "",
				'current_cond' => "", 
				'measurements' => measurement_json
			}.as_json
		else
			json_by_loc = {'date' => date, 
				'current_temp' => measure_latest.temp,
				'current_cond' => measure_latest.condition, 
				'measurements' => measurement_json
			}.as_json
		end

		return json_by_loc
		
	end
end
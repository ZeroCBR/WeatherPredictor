require_relative './formater'
require_relative './prediction_regression'

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

		locations_info_all = locations_needed.collect do |l|
			measure_total = []
			measure_each = Measurement.get_data_by_loc(l.id, time)
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

	def self.predict_by_lat_long latitude, longitude, period
		time=[]
		temp=[]
		precip=[]
		windDir=[]
		windSpeed=[]		
		@predictions=[]
		if Location.location_mapping(latitude, longitude)!=nil
			location=Location.location_mapping(latitude, longitude)
		else
			location=Location.location_similar(latitude, longitude)
		end
		current=Parser.data_for_target_from_api(location).first
		@predictions.push({"0"=>{"time"=>current.time, "rain"=>{"value"=>current.precip, "probability"=>"1"}, "temp"=>{"value"=>current.temp, "probability"=>"1"}, "windDir"=>{"value"=>current.windDir, "probability"=>"1"}, "windSpeed"=>{"value"=>current.windSpeed, "probability"=>"1"}}})				
		measurements=Measurement.get_history(location)
		measurements.each do |measurement|
			time.push(measurement.time.to_i)
			temp.push(measurement.temp.to_f)
			precip.push(measurement.precip.to_f)
			windDir.push(measurement.windDir.to_i)
			windSpeed.push(measurement.windSpeed.to_f)
		end
		ptemp=PredictionRegression.new(time,temp, period.to_i)
		predict_temp, pro_temp=ptemp.executeRegression
		pprecip=PredictionRegression.new(time,precip, period.to_i)
		predict_precip, pro_precip=pprecip.executeRegression
		pwindDir=PredictionRegression.new(time,windDir, period.to_i)
		predict_windDir, pro_windDir=pwindDir.executeRegression
		pwindSpeed=PredictionRegression.new(time,windSpeed, period.to_i)
		predict_windSpeed, pro_windSpeed=pwindSpeed.executeRegression		
		(1..period.to_i/10).each do |i|
			@predictions.push({i*10=>{"time"=>current.time+i*10*60, "rain"=>{"value"=>predict_precip[i-1], "probability"=>pro_precip[i-1]}, "temp"=>{"value"=>predict_temp[i-1], "probability"=>pro_temp[i-1]}, "windDir"=>{"value"=>predict_windDir[i-1], "probability"=>pro_windDir[i-1]}, "windSpeed"=>{"value"=>predict_windSpeed[i-1], "probability"=>pro_windSpeed}}})
		end
		main_hash = {"latitude" => latitude, "longitude" => longitude, "predictions" => @predictions}	
		return main_hash
	end
end
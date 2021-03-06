require_relative './formater'
require_relative './prediction_regression'

class Extractor
	def self.data_loc_by_pcode(pcode, date)
		postcode = Postcode.find_by_postcode(pcode)
		if postcode != nil
			locations_needed = Location.where(postcode_id: postcode.id)

			date.match /(\d{2})-(\d{2})-(\d{4})/
			time = Time.new($3,$2,$1)

			locations_info_all = locations_needed.collect do |l|
				measure_total = []
				measure_each = Measurement.get_data_by_loc(l.id, time)
				measure_total = measure_each.collect do |m|
					measure_total =
					{
						'time'=> Format.time_hh_mm_ss(m.time),
						'temp'=> m.temp,
						'precip'=> m.precip,
						'wind_direction'=> Format.windDir(m.windDir),
						'wind_speed'=> m.windSpeed,
					}
				end
				location_info =
				{
					'id'=> l.name,
					'lat'=> l.latitude,
					'lon'=> l.longitude,
					'last_update'=> Format.time_dd_mm_yyyy(l.updated_at),
					'measurements'=> measure_total
				}

			end
			return {
					'date'=> date,
					'locations'=> locations_info_all
						}.as_json
		else
			return Hash.new
		end
	end

	def self.data_by_loc_id(loction_id, date)
		date.match /(\d{2})-(\d{2})-(\d{4})/
		time = Time.new($3,$2,$1)

		measurements_data = Measurement.get_data_by_loc(loction_id, time)
		measurement_now = Measurement.get_data_in_30min(loction_id)
		measure_latest = measurement_now.last
		measurement_json=[]

		measurements_data.each do |measure|
			each_json = {
				'time' => Format.time_hh_mm_ss(measure.time),
				'temp' => measure.temp,
				'precip' => measure.precip.to_s,
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
		location=Location.location_mapping(latitude, longitude)
		if location.length == 0
			location= Location.location_similar(latitude, longitude)
		end
		puts(location)
		hash_predictions, array_predictions = self.predict(location, period)
		main_hash = {'latitude' => latitude, 'longitude' => longitude, 'predictions' => hash_predictions}
		main_array = {'latitude' => latitude, 'longitude' => longitude, 'predictions' => array_predictions}

		return main_hash, main_array
	end

	def self.predict_by_postcode(pcode, period)
		postcode = Postcode.find_by_postcode(pcode)
		if postcode != nil
			location_list = Location.where(postcode_id: postcode.id)
			hash_records = []
			array_records = []
			location_list.each do
				|location|
				hash_record, array_record =self.predict([location],period)
				hash_records.push({'location_id' => location.name, 'predictions' => hash_record})
				array_records.push({'location_id' => location.name, 'predictions' => array_record})
			end
			return hash_records, array_records
		else
			return []
		end
	end

	def self.predict(location, period)
		time=[]
		temp=[]
		precip=[]
		windDir=[]
		windSpeed=[]
		hash_predictions={}
		array_predictions=[]
		if Measurement.get_history(location).size!=0
			current=Parser.data_for_target_from_api(location).first
			hash_predictions.merge!({"0"=>{"time"=>Format.time_dd_mm_yyyy(current.time), "rain"=>{"value"=>current.precip, "probability"=>"1"}, "temp"=>{"value"=>current.temp, "probability"=>"1"}, "windDir"=>{"value"=>current.windDir.to_i%360, "probability"=>"1"}, "windSpeed"=>{"value"=>current.windSpeed, "probability"=>"1"}}})
			array_predictions.push({"0"=>{"time"=>Format.time_dd_mm_yyyy(current.time), "rain"=>{"value"=>current.precip, "probability"=>"1"}, "temp"=>{"value"=>current.temp, "probability"=>"1"}, "windDir"=>{"value"=>current.windDir.to_i%360, "probability"=>"1"}, "windSpeed"=>{"value"=>current.windSpeed, "probability"=>"1"}}})		
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
				hash_predictions.merge!({"#{i*10}"=>{"time"=>Format.time_dd_mm_yyyy(current.time+i*10*60), "rain"=>{"value"=>predict_precip[i-1].round(4), "probability"=>pro_precip[i-1].round(4)}, "temp"=>{"value"=>predict_temp[i-1].round(4), "probability"=>pro_temp[i-1].round(4)}, "windDir"=>{"value"=>predict_windDir[i-1].to_i%360.round(4), "probability"=>pro_windDir[i-1].round(4)}, "windSpeed"=>{"value"=>predict_windSpeed[i-1].round(4), "probability"=>pro_windSpeed[i-1].round(4)}}})
				array_predictions.push({"#{i*10}"=>{"time"=>Format.time_dd_mm_yyyy(current.time+i*10*60), "rain"=>{"value"=>predict_precip[i-1].round(4), "probability"=>pro_precip[i-1].round(4)}, "temp"=>{"value"=>predict_temp[i-1].round(4), "probability"=>pro_temp[i-1].round(4)}, "windDir"=>{"value"=>predict_windDir[i-1].to_i%360.round(4), "probability"=>pro_windDir[i-1].round(4)}, "windSpeed"=>{"value"=>predict_windSpeed[i-1].round(4), "probability"=>pro_windSpeed[i-1].round(4)}}})
			end
		end		
		return hash_predictions, array_predictions
	end

	def self.locations_to_hash
		@locations = Location.all

		date=Time.now.strftime("%d-%m-%Y")

		location_list=[]

		@locations.each do |loc|
			each_loc_hash = {
				'id' => loc.name,
				'lat' => loc.latitude,
				'lon' => loc.longitude,
				'last_update' => Format.time_dd_mm_yyyy(loc.updated_at)
			}
			location_list << each_loc_hash

		end

		locations_hash={
			'date' => date,
			'locations' => location_list
		}

		return locations_hash
	end
end
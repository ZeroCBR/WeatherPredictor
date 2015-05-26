require_relative '../../lib/prediction_regression'
require_relative '../../lib/parser'
class PredictController < ApplicationController
	def predict_by_pcode

	end

	def predict_by_LatLon
		latitude=params[:lat]
		longitude=params[:long]
		period=params[:period]
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
		render plain: main_hash.inspect						
	end

	private
		# Never trust parameters from the scary internet, only allow the white list through.
		def predict_params
			params.require(:predict).permit(:lat, :long, :period, :post_code)
		end
	end

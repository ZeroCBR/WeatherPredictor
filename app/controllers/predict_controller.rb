require_relative '../../lib/prediction_regression'
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
		if Location.location_mapping(latitude, longitude)!=nil
			location_id=Location.location_mapping(latitude, longitude)
		else
			location_id=Location.location_similar(latitude, longitude)
		end
		# render plain: Location.location_similar(latitude, longitude).inspect
		measurements=Measurement.get_history(location_id)
		# render plain: measurements.inspect
		measurements.each do |measurement|
			time.push(measurement.time.to_i)
			temp.push(measurement.temp.to_f)
			precip.push(measurement.precip.to_f)
			windDir.push(measurement.windDir.to_i)
			windSpeed.push(measurement.windSpeed.to_f)
		end
		# render plain: time.inspect
		ptemp=PredictionRegression.new(time,temp, period.to_i)
		predict_temp=ptemp.executeRegression
		pprecip=PredictionRegression.new(time,precip, period.to_i)
		predict_precip=pprecip.executeRegression
		pwindDir=PredictionRegression.new(time,windDir, period.to_i)
		predict_windDir=pwindDir.executeRegression
		pwindSpeed=PredictionRegression.new(time,windSpeed, period.to_i)
		predict_windSpeed=pwindSpeed.executeRegression

		# render plain: [predict_temp,predict_precip, predict_windDir, predict_windSpeed].inspect
		render plain: [time, predict_temp,predict_precip, predict_windDir, predict_windSpeed].inspect
	end

	private
		# Never trust parameters from the scary internet, only allow the white list through.
		def predict_params
			params.require(:predict).permit(:lat, :long, :period, :post_code)
		end
	end

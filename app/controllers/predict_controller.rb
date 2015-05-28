require 'json'
require_relative '../../lib/prediction_regression'
require_relative '../../lib/parser'
require_relative '../../lib/extract_data'
class PredictController < ApplicationController
	def predict_by_LatLon
		latitude=params[:lat]
		longitude=params[:long]
		period=params[:period]
		output = Extractor.predict_by_lat_long(latitude, longitude, period)	
		render json: output			
	end

	def predict_by_LatLon_table
		latitude=params[:lat]
		longitude=params[:long]
		period=params[:period]
		@table_hash = Extractor.predict_by_lat_long(latitude, longitude, period)	
	end

	def predict_by_postcode
		postcode = params[:post_code]
		period = params[:period]
		output = Extractor.predict_by_postcode(postcode, period)
		render json: output
	end

	private
		# Never trust parameters from the scary internet, only allow the white list through.
		def predict_params
			params.require(:predict).permit(:lat, :long, :period, :post_code)
		end
	end

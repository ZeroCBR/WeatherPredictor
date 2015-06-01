require 'json'
require_relative '../../lib/prediction_regression'
require_relative '../../lib/parser'
require_relative '../../lib/extract_data'
class PredictController < ApplicationController
	def predict_by_LatLon
		latitude=params[:lat]
		longitude=params[:long]
		period=params[:period]
		table_json, @table_hash = Extractor.predict_by_lat_long(latitude, longitude, period)
		puts table_json
		puts @table_hash
		respond_to do |format|
			format.html
			format.json { render json: table_json }
		end	
	end	

	def predict_by_postcode
		postcode = params[:post_code]
		period = params[:period]
		predict_by_pcode_json, @predict_by_pcode = Extractor.predict_by_postcode(postcode, period)
		respond_to do |format|
			format.html
			format.json { render json: predict_by_pcode_json }
		end
	end

	private
		# Never trust parameters from the scary internet, only allow the white list through.
		def predict_params
			params.require(:predict).permit(:lat, :long, :period, :post_code)
		end
	end
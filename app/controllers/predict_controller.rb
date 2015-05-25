class PredictController < ApplicationController
	def predict_by_pcode

	end

	def predict_by_LatLon
		latitude=params[:lat]
		longitude=params[:long]
		period=params[:period]
		render plain: Location.location_mapping(latitude, longitude).inspect
		if location_mapping(latitude, longitude)

		else

		end
	end

	private
		# Never trust parameters from the scary internet, only allow the white list through.
		def predict_params
			params.require(:predict).permit(:lat, :long, :period, :post_code)
		end
	end

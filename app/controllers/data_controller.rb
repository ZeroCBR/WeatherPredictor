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


		ext_by_loc = Extractor.data_by_loc_json(loctionId, date)

		@hash_by_loc = ext_by_loc

		respond_to do |format|
   format.html
   format.json { render json: @hash_by_loc }
		end

	end

	def listLocations
		@locations = Location.all

		loc_to_hash = Extractor.locations_to_hash

		respond_to do |format|
   format.html
   format.json { render json: loc_to_hash }
		end

	end
end

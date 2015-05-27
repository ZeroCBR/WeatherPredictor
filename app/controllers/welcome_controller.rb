require_relative '../../lib/extract_data'


class WelcomeController < ApplicationController
  def data_pcode
  	# pcode = "3678"
  	# date = "26-05-2015"
    @pcode = params[:post_code]
		@date_to_search = params[:date]
		data_hash = Extractor.by_pcode(@pcode,@date_to_search)
		@locations = data_hash["locations"]
	end

  def index
  	
  end

  def data_loc
    loc_name = "CHARLTON"
    # params[:location_id]
    date = "26-05-2015"
    # params[:date]
    location = Location.find_by_name(loc_name)
    loctionId = location.id

    json = Extractor.data_by_loc_json(loctionId, date)

    @json_by_loc = json
    
  end
end

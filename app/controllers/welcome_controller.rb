require_relative '../../lib/extract_data'


class WelcomeController < ApplicationController
  def data_pcode
  pcode = params[:post_code]
		date = params[:date]
		#data_hash = Extactor.by_pcode(pcode,date)
		@locations = Location.all

		
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

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
end

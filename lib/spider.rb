require 'nokogiri'
require_relative 'geography_data_provider'
require_relative 'forecast_data_provider'

class Spider

  def extract_location
    url = 'http://www.bom.gov.au/vic/observations/vicall.shtml'
    result =Array.new
    @doc = Nokogiri::HTML(open(url))
    weather_log_list = @doc.css('tbody tr')
    weather_log_list.each {
        |weather_log|
      location_info_node = weather_log.css('a')[0]
      geography_data_provider = GeographyDataProvider.new
      location = geography_data_provider.extract_location_info(location_info_node)
      result.push(location)
      sleep(1)
    }
    return result
  end

  def extract_weather
    location_list = Location.all
    location_list.each do
      |location|
      fore_data_provider = ForecastDataProvider.new
      weather_log = fore_data_provider.extract_data(location)
      weather_log.save
    end
  end
end
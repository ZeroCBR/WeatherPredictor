require 'nokogiri'
require_relative 'geography_data_provider'
require_relative 'forecast_data_provider'

class Spider

  def Spider.extract_location
    url = 'http://www.bom.gov.au/vic/observations/vicall.shtml'
    result =Array.new
    @doc = Nokogiri::HTML(open(url))
    weather_log_list = @doc.css('tbody tr')
    weather_log_list.each {
        |weather_log|
      location_info_node = weather_log.css('a')[0]
      location = GeographyDataProvider.extract_location_info(location_info_node)
      result.push(location)
      sleep(1)
    }
    return result
  end

  def Spider.extract_weather
    location_list = Location.all
    location_list.each do
      |location|
      weather_log = ForecastDataProvider.extract_data(location)
      weather_log.save
    end
  end
end
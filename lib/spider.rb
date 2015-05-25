require 'nokogiri'
require_relative 'geography_data_provider'
require_relative 'forecast_data_provider'

class Spider
  def initialize
    @key_array = %w(f0c8b5b69a7cd82e11fdabc6949a5c97 3cfd5e179f93cb779b3eb58d9f8c37ce 0921b86f171d0c3ded523060df73dcff e8bf417079091cd350f86d3badd5bcfd)
  end
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
      index = Time.now.to_i % @key_array.length
      api_key = @key_array[index]
      fore_data_provider = ForecastDataProvider.new(api_key)
      weather_log = fore_data_provider.extract_data(location)
      weather_log.save
    end
  end
end
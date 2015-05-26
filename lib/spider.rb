require 'nokogiri'
require_relative 'geography_data_provider'
require_relative 'forecast_data_provider'

class Spider

  def Spider.extract_location
    return GeographyDataProvider.extract_location
  end

  def Spider.extract_weather
    location_list = Location.all
    location_list.each do
      |location|
      weather_log = ForecastDataProvider.extract_data(location)
      weather_log.save
    end
  end

  def Spider.extract
    Spider.extract_location
    Spider.extract_weather
  end
end
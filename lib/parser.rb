require_relative 'spider'
require_relative 'forecast_data_provider'
require_relative '../app/models/measurement'
require_relative '../app/models/location'

class Parser
  def Parser.data_from_bom
    return BomDataProvider.extract_weather_with_location('vic','observations','vicall')
  end

  def Parser.data_for_all_location_from_api
    return Spider.extract_weather
  end

  def Parser.data_flush
    Spider.extract
  end

  def Parser.data_for_target_from_api(location_list)
    result = Array.new
    location_list.each do
      |location|
      weather_log = ForecastDataProvider.extract_data(location)
      result.push(weather_log)
    end
  end
end


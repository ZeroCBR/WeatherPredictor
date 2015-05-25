require 'nokogiri'
require 'open-uri'

require_relative '../app/models/measurement'
require_relative '../app/models/location'
require_relative 'geography_data_provider'

class BomDataProvider

  def BomDataProvider.extract_weather_with_location(state, channel, location_parameter)
    result =Array.new
    @doc = Nokogiri::HTML(open("http://www.bom.gov.au/#{state}/#{channel}/#{location_parameter}.shtml"))
    weather_log_list = @doc.css('tbody tr')
    weather_log_list.each {
        |weather_log|
      location_info_node = weather_log.css('a')[0]
      location = GeographyDataProvider.extract_location_info(location_info_node)
      weather_info_node_list = weather_log.css('td')
      weather_info = self.extract_weather_info(weather_info_node_list)
      weather_log = Measurement.new
      weather_log.location_id = location.id
      weather_log.temp = weather_info['temperature']
      #weather_log.dew_point = weather_info['dew-point']
      weather_log.precip = weather_info['rainfall-amount']
      weather_log.windDir = Converter.translate_direction_to_degree(weather_info['wind-direction'])
      weather_log.windSpeed = weather_info['wind-speed']
      weather_log.condition = '-'
      weather_log.time = Time.now
      #weather_log.save
      result.push(weather_log)
    }
    return result
  end

  def BomDataProvider.extract_weather_info(weather_info_node_list)
    result = Hash.new
    weather_info_node_list.each {
        |weather_info_node|
      header = weather_info_node[:headers]
      if header.include?('obs-temp')
        result['temperature'] = weather_info_node.content.to_f
      elsif header.include?('obs-dewpoint')
        result['dew-point'] = weather_info_node.content.to_f
      elsif header.include?('obs-wind-dir')
        result['wind-direction'] = weather_info_node.content
      elsif header.include?('obs-wind-spd-kph')
        result['wind-speed'] = weather_info_node.content.to_f
      elsif header.include?('obs-rainsince9am')
        result['rainfall-amount'] = weather_info_node.content.to_f
      elsif header.include?('obs-datetime')
        result['date-time'] = Converter.format_datetime(weather_info_node.content)
      end
    }
    return result
  end
end
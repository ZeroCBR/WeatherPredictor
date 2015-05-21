require 'nokogiri'
require 'open-uri'

require_relative 'measurement'
require_relative 'location'

class BomDataProvider

  def initialize(state, channel)
    @connection_string = 'http://www.bom.gov.au/' + state + '/' + channel + '/'
  end

  def extract_data(location_parameter)
    result =Array.new
    @doc = Nokogiri::HTML(open(@connection_string + location_parameter + '.shtml'))
    weather_log_list = @doc.css('tbody tr')
    weather_log_list.each {
        |weather_log|
      location_info_node = weather_log.css('a')[0]
      location = self.extract_location_info(location_info_node)
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
      weather_log.time = Converter.format_datetime(weather_info['date-time'])
      #weather_log.save
      result.push(weather_log)
    }
    return result
  end

  def extract_location_info(location_info_node)
    link = location_info_node[:href]
    name = location_info_node.content
    location = Location.find_by_name(name)
    if location == nil
      geography_data_provider = GeographyDataProvider.new()
      location_position = geography_data_provider.extract_bom_data('http://www.bom.gov.au' + link)
      location = Location.new
      location.latitude = location_position['latitude']
      location.longitude = location_position['longitude']
      location.name = name
      double_check_location = Location.find_by_name(name)
      location.postcode = geography_data_provider.extract_post_code(name)
      if  double_check_location == nil
        location.save
      end
      return location
    else
      return location
    end
  end

  def extract_weather_info(weather_info_node_list)
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
require 'nokogiri'
require 'open-uri'
require 'json'
require_relative 'google_map_api_data_provider'
require_relative '../app/models/location'
require_relative '../app/models/postcode'
OpenSSL::SSL::VERIFY_PEER=OpenSSL::SSL::VERIFY_NONE
# require_relative 'location'
# require_relative 'postcode'

class GeographyDataProvider

  def extract_position_details(connection_string)
    doc = Nokogiri::HTML(open(connection_string))
    result = Hash.new
    if doc != nil
      node_list = doc.css('.stationdetails td')
      name = node_list[2].content.strip
      name['Name: '] = ''
      latitude = node_list[3].content.strip
      latitude['Lat: '] = ''
      longitude = node_list[4].content.strip
      longitude['Lon: '] = ''
      result['name'] = name
      result['latitude'] = latitude.to_f
      result['longitude'] = longitude.to_f
    end
    return result
  end

  def extract_location_info(location_info_node)
    link = location_info_node[:href]
    location_position = extract_position_details('http://www.bom.gov.au' + link)
    location = Location.find_by_name(location_position['name'])
    if location == nil
      #location_position = extract_latitude_longitude('http://www.bom.gov.au' + link)
      location = Location.new
      location.latitude = location_position['latitude']
      location.longitude = location_position['longitude']
      location.name = location_position['name']
      location.postcode = extract_post_code(location_position['name'], location_position['latitude'], location_position['longitude'])
      puts("Name:#{location.name},Latitude:#{location.latitude},Longitude:#{location.longitude},Postcode:#{location.postcode.postcode}")
      double_check_location = Location.find_by_name(location.name)
      if double_check_location == nil
        location.save
      end
      return location
    else
      return location
    end
  end

  def extract_post_code(address, latitude, longitude)
    google_api_data_provider = GoogleMapApiDataProvider.new
    code = google_api_data_provider.extract_post_code(address, latitude, longitude)
    if code.length != 4 || (code.to_i < 3000 || code.to_i > 3999)
      code = '9999'
    end
    postcode = Postcode.find_by_postcode(code)
    if postcode == nil
      postcode = Postcode.new
      postcode.postcode = code
      double_check_postcode = Postcode.find_by_postcode(code)
      if double_check_postcode
        postcode.save
      end
    end
    return postcode
  end
end

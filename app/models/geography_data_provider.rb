require 'nokogiri'
require 'open-uri'
require_relative 'location'
require_relative 'postcode'

class GeographyDataProvider
  @key_array = ['AIzaSyDAs8cXzygtk03zoh5a9DlKOuPevDo203k', 'AIzaSyBRwgsM4kHsWRUcNFqvM6wCTzoK50xsAQs']

  def initialize
    @connection_string = 'https://maps.googleapis.com/maps/api/geocode/json'
  end

  # @return [Hash]
  def extract_latitude_longitude(connection_string)
    doc =  Nokogiri::HTML(open(connection_string))
    result = Hash.new
    if doc != nil
      node_list = doc.css('.stationdetails td')
      latitude = node_list[3].content
      latitude[' Lat: '] = ''
      longitude = node_list[4].content
      longitude[' Lon: '] = ''
      result['latitude'] = latitude.to_f
      result['longitude'] = longitude.to_f
    end
    return result
  end

  def extract_location_info(location_info_node)
    link = location_info_node[:href]
    name = location_info_node.content
    location = Location.find_by_name(name)
    if location == nil
      location_position = extract_latitude_longitude('http://www.bom.gov.au' + link)
      location = Location.new
      location.latitude = location_position['latitude']
      location.longitude = location_position['longitude']
      location.name = name
      location.postcode = extract_post_code(name)
      double_check_location = Location.find_by_name(name)
      if  double_check_location == nil
        location.save
      end
      return location
    else
      return location
    end
  end

  def extract_post_code(address)
    format_address = address,lstrip.lstrip.gsub(/ /, '+')
    index = Time.to_i % @key_array.length
    api_key = @key_array[index]
    result = JSON.parser(open("#{@connection_string}?key=#{api_key}&address=#{format_address}"))['results']
    postcode = result[0][6]['long_name']
    post_code = Postcode.find_by_postcode(postcode)
    if post_code == nil
      post_code =Postcode.new
      post_code.postcode = postcode
      double_check_postcode = Postcode.find_by_postcode(postcode)
      if double_check_postcode == nil
        post_code.save
      end
    end
    return post_code
  end
end
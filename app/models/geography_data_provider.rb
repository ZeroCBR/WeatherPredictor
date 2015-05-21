require 'nokogiri'
require 'open-uri'

class GeographyDataProvider
  @key_array = ['AIzaSyDAs8cXzygtk03zoh5a9DlKOuPevDo203k', 'AIzaSyBRwgsM4kHsWRUcNFqvM6wCTzoK50xsAQs']

  def initialize
    @connection_string = 'https://maps.googleapis.com/maps/api/geocode/json'
  end

  # @return [Hash]
  def extract_bom_data(connection_string)
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

  def extract_post_code(address)
    format_address = address,lstrip.lstrip.gsub(/ /, '+')
    index = Time.to_i % @key_array.length
    api_key = @key_array[index]
    result = JSON.parser(open("#{@connection_string}?key=#{api_key}&address=#{format_address}"))['results']
    return result[0][6]['long_name']
  end
end
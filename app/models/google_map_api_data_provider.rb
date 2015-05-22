require 'json'
require 'open-uri'

OpenSSL::SSL::VERIFY_PEER=OpenSSL::SSL::VERIFY_NONE

class GoogleMapApiDataProvider
  def initialize
    @connection_string = 'https://maps.googleapis.com/maps/api/geocode/json'
    @key_array = %w(AIzaSyDAs8cXzygtk03zoh5a9DlKOuPevDo203k AIzaSyBRwgsM4kHsWRUcNFqvM6wCTzoK50xsAQs)
  end

  def parse_response(request_address)
    format_address = request_address.strip.gsub(/ /, '+')
    index = Time.now.to_i % @key_array.length
    api_key = @key_array[index]
    puts("#{@connection_string}?key=#{api_key}&address=#{format_address}")
    responses = JSON.parse(open("#{@connection_string}?key=#{api_key}&address=#{format_address}").read)['results']
    # puts(responses)
    result = Hash.new
    responses.each do
      |response|
      address_components = response['address_components']
      address = Hash.new
      address_components.each do
        |component|
        type = component['types']
        address.store('Establishment', component['long_name']) if type.include?('establishment')
        address.store('Route', component['long_name']) if type.include?('route')
        address.store('Locality', component['long_name']) if type.include?('locality')
        address.store('State', component['long_name']) if type.include?('administrative_area_level_1')
        address.store('Country', component['long_name']) if type.include?('country')
        address.store('PostCode', component['long_name']) if type.include?('postal_code')
      end
      result.store(response['geometry'], address)
    end
    return result
  end

  def get_target_geometry(response_pool, latitude, longitude)
    if response_pool != nil
      distance = Hash.new
      response_pool.each do
        |geometry, address|
        location_latitude = geometry['location']['lat']
        location_longitude = geometry['location']['lng']
        distance.store((latitude - location_latitude) ** 2 + (longitude - location_longitude) ** 2, geometry)
      end
      key = get_least(distance.keys)
      return distance[key]
    end
    return nil
  end

  def get_least(array)
    if array != nil
      result = array[0]
      array.each do
        |current|
        if result > current
          result = current
        end
      end
      return result
    end
    return nil
  end

  def extract_post_code(address, latitude, longitude)
    response_pool = parse_response(address)
    response = response_pool[get_target_geometry(response_pool, latitude, longitude)]
    return response['PostCode']
  end
end
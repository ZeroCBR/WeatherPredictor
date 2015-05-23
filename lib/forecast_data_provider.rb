require 'open-uri'
require 'json'
require_relative 'measurement'
require_relative 'location'
#Created by Dongyu Zhao, 714138
class ForecastDataProvider

  def initialize(api_key)
    @api_key = api_key
  end

  def extract_data(location)
    forecast = JSON.parse(open("https://api.forecast.io/forecast/#{@api_key}/#{location.latitude},#{location.longitude}?units=si&exclude=minutely,hourly,daily,alerts,flags").read)['currently']
    weather_log = Measurement.new
    weather_log.location_id = location.id
    weather_log.temp = forecast['temperature']
    weather_log.condition = forecast['icon']
    weather_log.precip = forecast['precipIntensity']
    weather_log.windSpeed = forecast['windSpeed']
    if weather_log.windSpeed == 0.0
      weather_log.windDir = '-'
    else
      weather_log.windDir = forecast['windBearing']
    end
    #weather_log.data_source = 'Forecast IO'
    weather_log.time = Time.at(forecast['time'])
    #weather_log.save
    return weather_log
  end

end
require 'open-uri'
require 'json'
require_relative '../app/models/measurement'
require_relative '../app/models/location'
#Created by Dongyu Zhao, 714138
class ForecastDataProvider
  @@current_index = 0
  def initialize
    @key_array = %w(f0c8b5b69a7cd82e11fdabc6949a5c97 3cfd5e179f93cb779b3eb58d9f8c37ce 0921b86f171d0c3ded523060df73dcff e8bf417079091cd350f86d3badd5bcfd c1e4b1644cd22ce35eae78a1e16e2c3a 41d21499c9d9c2cd1904f2889bac9007)
  end

  def extract_data(location)continue_try = true
    while continue_try
      if @@current_index < @key_array.length
        api_key = @key_array[@@current_index]
        begin
          puts(@@current_index)
          puts(api_key)
          forecast = JSON.parse(open("https://api.forecast.io/forecast/#{api_key}/#{location.latitude},#{location.longitude}?units=si&exclude=minutely,hourly,daily,alerts,flags").read)['currently']
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
          puts("Name:#{weather_log.location.name},Time:#{weather_log.time},Temp:#{weather_log.temp},Condition:#{weather_log.condition},Precip:#{weather_log.precip},Speed:#{weather_log.windSpeed},Dir:#{weather_log.windDir}")
          #weather_log.save
          continue_try = false
          return weather_log
        rescue Exception => e
          continue_try = true
          puts(@@current_index)
          puts(e)
          puts('Current Forecast Api Used Up')
          @@current_index = @@current_index + 1
        end
      else
        continue_try = false
        raise('All Forecast Api Used Up')
      end
    end
  end

end
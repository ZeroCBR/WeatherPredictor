require 'open-uri'
require 'json'
require_relative '../app/models/measurement'
require_relative '../app/models/location'
require_relative 'api_key_dispatcher'
#Created by Dongyu Zhao, 714138
class ForecastDataProvider
  @@key_dispatcher = ApiKeyDispatcher.new(
                %w(6734b27177d8e08f1cae44ae93f76f74
                  2833e235068626ffe542e57b9d4c8b3b
                  51dfe9540e4b38053f4a29bdfebb243b
                  90f1e3a469ccd3e3c537db5f3fe27d12
                  4bfd742a5c6ba961436f914aa34861f1
                  6375dd09e70aad9871d22fbe247a3fe7
                  cc537c93570404eb89868a4c207ef9db
                  815ee032c3aef0a8234e9a9434062e4c
                  6c030b5599e5637c7e64d03eb6375e06
                  f0c8b5b69a7cd82e11fdabc6949a5c97
                  3cfd5e179f93cb779b3eb58d9f8c37ce
                  0921b86f171d0c3ded523060df73dcff
                  e8bf417079091cd350f86d3badd5bcfd
                  c1e4b1644cd22ce35eae78a1e16e2c3a
                  41d21499c9d9c2cd1904f2889bac9007
                  e337ca42a6dadf196fe1d372e07e94fd)
  )

  def ForecastDataProvider.extract_data(location)
    continue_try = true
    puts(location.name)
    while continue_try
      api_key = @@key_dispatcher.get_current_key
      if api_key != nil
        puts("Current Key:#{api_key}")
        begin
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
          puts("Current Key:#{api_key}")
          puts('Current Forecast Api Used Up')
          puts("Exception Occurred:#{e}")
          @@key_dispatcher.get_a_new_key
        end
      else
        continue_try = false
        raise('All Forecast Api Used Up')
      end
    end
  end

end
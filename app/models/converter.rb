class Converter
  def Converter.temperature_f_to_c(temperature_in_f)
    result = (temperature_in_f - 32.0) / 1.8
    return result.round(1)
  end

  def Converter.translate_degree_to_direction(direction_degree)
    case direction_degree
      when 0..10
        return 'N'
      when 10..35
        return 'NNE'
      when 35..55
        return 'NE'
      when 55..80
        return 'ENE'
      when 80..100
        return 'E'
      when 100..125
        return 'ESE'
      when 125..145
        return 'SE'
      when 145..170
        return 'SSE'
      when 170..190
        return 'S'
      when 190..215
        return 'SSW'
      when 215..235
        return 'SW'
      when 235..260
        return 'WSW'
      when 260..280
        return 'w'
      when 280..305
        return 'WNW'
      when 305..325
        return 'NW'
      when 325..350
        return 'NNW'
      when 350..360
        return 'N'
      else
        return '-'
    end
  end

  def Converter.translate_direction_to_degree(direction)
    case direction
      when 'N'
        return 0
      when 'NNE'
        return 23
      when 'NE'
        return 45
      when 'ENE'
        return 67
      when 'E'
        return 90
      when 'ESE'
        return 112
      when 'SE'
        return 135
      when 'SSE'
        return 157
      when 'S'
        return 180
      when 'SSW'
        return 202
      when 'SW'
        return 225
      when 'WSW'
        return 247
      when 'W'
        return 270
      when 'WNW'
        return 292
      when 'NW'
        return 315
      when 'NNW'
        return 337
      else
        return -1
    end
  end

  def Converter.translate_offset_to_datetime(time)
    return Time.at(time).to_datetime
  end

  def Converter.format_datetime(source_string)
    time_digit = source_string.split(/\D/)
    time_str = source_string.split(/\d/)
    time_now = Time.now
    if time_digit[0] != time_now.mday
      time_now = time_now - 86400
      if time_str[2] == 'pm'
        time_digit[1] = (time_digit[1].to_i + 12).to_s
      end
    end
    time = Time.new(time_now.year, time_now.month, time_now.mday, time_digit[1], time_digit[2], 0, '+10:00')
    return time.to_datetime
  end
end
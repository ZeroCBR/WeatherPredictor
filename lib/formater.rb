class Format
	def self.windDir angle #convert angle to direction
		ang = angle.to_f
		case ang
		when 348.76..360
			return "N"
		when 0..11.25
			return "N"
		when 11.26..33.75
			return "NNE"
		when 33.76..56.25
			return "NE"
		when 56.26..78.75
			return "ENE"
		when 78.76..101.25
			return "E"
		when 101.26..123.75
			return "ESE"
		when 123.76..146.25
			return "SE"
		when 146.26..168.75
			return "SSE"
		when 168.76..191.25
			return "S"
		when 191.26..213.75
			return "SSW"
		when 213.76..236.25
			return "SW"
		when 236.26..258.75
			return "WSW"
		when 258.76..281.25
			return "W"
		when 281.76..303.75
			return "WNW"
		when 303.76..326.25
			return  "NW"
		when 326.26..348.75
			return "NNW"
		else
			return "CALM"
		end
	end

end
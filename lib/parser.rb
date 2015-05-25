class Parser
  def Parser.get_from_bom
    return BomDataProvider.extract_weather_with_location('vic','observations','vicall')
  end

  def Parser.get_from_api
    return Spider.extract_weather
  end
end


class Converter
  WIND_DIRS = %i{ N NNE NE ENE E ESE SE SSE S SSW SW WSW W WNW NW NNW }.freeze
  WIND_DIR_MAPPINGS = WIND_DIRS.each_with_index.inject({}) { |m, (dir, index)| m[dir] = index * 360.0 / WIND_DIRS.size; m }.freeze

  def Converter.translate_direction_to_degree(direction)
    return WIND_DIR_MAPPINGS[direction.to_sym]
  end

end
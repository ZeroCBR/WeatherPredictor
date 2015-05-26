class ApiKeyDispatcher
  def initialize(keys)
    @key_pool = keys
    @key_index_map = Time.now.to_i % @key_pool.length
    @current_index = @key_index_map
    @reversed = false
  end

  def get_current_key
    return @key_pool[@current_index]
  end

  def get_a_new_key
    @current_index = @current_index + 1
    if @reversed && @current_index >= @key_index_map
      return nil
    end
    if @current_index >= @key_pool.length
      @current_index = @current_index % @key_pool.length
      @reversed = true
    end
    return get_current_key
  end
end
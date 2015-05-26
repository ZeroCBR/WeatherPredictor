class ApiKeyDispatcher
  def initialize(keys)
    @key_pool = keys
    @key_index_map = Time.now.to_i % @key_pool.length
    @current_index = @key_index_map
    @key_count = 1
  end

  def get_current_key
    puts("Current:#{@current_index}")
    puts("Current:#{@key_index_map}")
    puts("Current:#{@key_count}")
    return @key_pool[@current_index]
  end

  def get_a_new_key
    @current_index = @current_index + 1
    @key_count = @key_count + 1
    if @key_count > @key_pool.length
      return nil
    end
    if @current_index >= @key_pool.length
      @current_index = @current_index % @key_pool.length
    end
    return get_current_key
  end
end
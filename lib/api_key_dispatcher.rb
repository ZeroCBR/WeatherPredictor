class ApiKeyDispatcher
  def initialize(keys)
    @key_pool = keys
    @initial_index = Time.now.to_i % @key_pool.length
    @current_index = @initial_index
    @key_count = 1
  end

  def get_current_key
    puts("Current:#{@current_index}")
    puts("Initial:#{@initial_index}")
    puts("Count:#{@key_count}")
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
class BlockWatcher
  class << self
    def record_call
      @total_calls = total_calls + 1
    end

    def total_calls
      @total_calls || 0
    end

    def reset
      @total_calls = 0
    end
  end
end

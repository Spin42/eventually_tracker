module EventuallyTracker
  class RedisBuffer

    def initialize(logger, configuration)
      @logger         = logger
      @configuration  = configuration
      @redis          = Redis.new(url: @configuration.redis_url)
    end

    def push_left(data)
      @redis.lpush(@configuration.redis_key, data.to_json)
    end

    def push_right(data)
      @redis.rpush(@configuration.redis_key, data.to_json)
    end

    def pop_left
      if @configuration.wait_events
        element = @redis.blpop(@configuration.redis_key)[1]
      else
        element = @redis.lpop(@configuration.redis_key)
      end
      element = JSON.parse(element) if element
      element
    end

    def size
      @redis.llen(@configuration.redis_key)
    end
  end
end

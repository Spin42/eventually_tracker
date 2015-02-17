require "base64"

module EventuallyTracker
  class RedisBuffer

    def initialize(logger, configuration)
      @logger         = logger
      @configuration  = configuration
      @redis          = Redis.new(url: @configuration.redis_url)
    end

    def push_left(data)
      mapped_object = map_complex_object(data)
      @redis.lpush(@configuration.redis_key, mapped_object.to_json)
    end

    def push_right(data)
      mapped_object = map_complex_object(data)
      @redis.rpush(@configuration.redis_key, mapped_object.to_json)
    end

    def pop_left
      if @configuration.wait_events
        element = @redis.blpop(@configuration.redis_key, 0)[1]
      else
        element = @redis.lpop(@configuration.redis_key)
      end
      element = JSON.parse(element) if element
      element
    end

    def size
      @redis.llen(@configuration.redis_key)
    end

    private
    def map_complex_object(object)
      if object.is_a?(Array)
        array = []
        object.each do | value |
          array.push(map_complex_object(value))
        end
        array
      elsif object.is_a?(Hash)
        hash = {}
        object.each do | key, value |
          hash[key] = map_complex_object(value)
        end
        hash
      elsif object.is_a?(ActionDispatch::Http::UploadedFile)
        {
          "file_name"     => object.original_filename,
          "content_type"  => object.content_type,
          "content"       => Base64.encode64(object.tempfile.read)
        }
      else
        object
      end
    end
  end
end

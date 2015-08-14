require "base64"

module EventuallyTracker
  class RedisBuffer

    def initialize(logger, configuration)
      @logger         = logger
      @configuration  = configuration
      @redis          = Redis.new(url: @configuration.redis_url)
    end

    def push_left(queues, data)
      queues.each do | queue |
        mapped_object = map_complex_object(data)
        @redis.lpush(key(queue), mapped_object.to_json)
      end
    end

    def push_right(queues, data)
      queues.each do | queue |
        mapped_object = map_complex_object(data)
        @redis.rpush(key(queue), mapped_object.to_json)
      end
    end

    def pop_left(queue)
      if @configuration.blocking_synchronize
        element = @redis.blpop(key(queue), 0)[1]
      else
        element = @redis.lpop(key(queue))
      end
      element = JSON.parse(element) if element
      element
    end

    def size(queue)
      @redis.llen(key(queue))
    end

    private
    def key(queue)
      @configuration.redis_key_prefix + ":" + queue.to_s
    end

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

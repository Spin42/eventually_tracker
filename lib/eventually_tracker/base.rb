module EventuallyTracker
  class Base
    def initialize(logger, buffer, configuration)
      @logger         = logger
      @configuration  = configuration
      @buffer         = buffer
    end

    def track_action(queues, action)
      action                    = sanitize(action)
      action[:application_name] = Rails.application.class.parent_name.underscore
      action[:type]             = "controller"
      action[:date_time]        = Time.now.utc
      @logger.info("Track action: " + JSON.pretty_generate(action))
      @buffer.push_right(queues, action)
    end

    def track_change(queues, change)
      return if change[:data].empty?
      change                    = sanitize(change)
      change[:application_name] = Rails.application.class.parent_name.underscore
      change[:type]             = "model"
      change[:date_time]        = Time.now.utc
      @logger.info("Track change: " + JSON.pretty_generate(change))
      @buffer.push_right(queues, change)
    end

    def sanitize(value)
      case value
      when Array
        value.map { |v| sanitize(v) }
      when Hash
        fitlered_value = {}
        value.each do |k, v|
          unless [:password, :password_confirmation].include?(k.to_sym)
            fitlered_value[k] = sanitize(v)
          end
        end
        fitlered_value
      else
        value
      end
    end
  end
end

module EventuallyTracker
  class Base

    def initialize(logger, buffer, configuration)
      @logger         = logger
      @configuration  = configuration
      @buffer         = buffer
    end

    def track_action(controller_name, action_name, action_uid, data)
      @logger.info "Track controller action #{action_uid} for #{controller_name}:#{action_name} => #{data}"
      @buffer.push_right({
        type: "controller",
        date_time: Time.zone.now,
        controller_name: controller_name,
        action_name: action_name,
        action_uid: action_uid,
        data: data
      })
    end

    def track_change(model_name, action_name, action_uid, data)
      if !data.empty? || action_name == :destroy
        @logger.info "Track model change for #{model_name} #{data} caused by #{action_uid}"
        @buffer.push_right({
          type: "model",
          model_name: model_name,
          action_name: action_name,
          action_uid: action_uid,
          date_time: Time.zone.now,
          data: data
        })
      end
    end
  end
end

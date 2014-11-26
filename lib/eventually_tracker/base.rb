module EventuallyTracker
  class Base

    def initialize(logger, buffer, configuration)
      @logger         = logger
      @configuration  = configuration
      @buffer         = buffer
    end

    def track_action(controller_name, action_name, action_uid, data, session_data)
      @logger.info "Track controller action #{action_uid} for #{controller_name}:#{action_name} => #{data} | #{session_data}"
      @buffer.push_right({
        type: "controller",
        date_time: Time.zone.now,
        controller_name: controller_name,
        action_name: action_name,
        action_uid: action_uid,
        data: data,
        session_data: session_data
      })
    end

    def track_change(model_name, action_name, action_uid, data)
      if !data.empty?
        @logger.info "Track model change for #{model_name}:#{action_name} #{data} caused by #{action_uid}"
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

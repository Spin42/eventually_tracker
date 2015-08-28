module EventuallyTracker
  class Base
    def initialize(logger, buffer, configuration)
      @logger         = logger
      @configuration  = configuration
      @buffer         = buffer
    end

    def track_action(queues, controller_name, action_name, response_code, action_uid,
                     data, session_data)
      event = {
        application_name: Rails.application.class.parent_name.underscore,
        type:             "controller",
        date_time:        Time.now.utc,
        controller_name:  controller_name,
        action_name:      action_name,
        action_uid:       action_uid,
        response_code:    response_code,
        data:             data,
        session_data:     session_data
      }
      @logger.info(event)
      @buffer.push_right(queues, event)
    end

    def track_change(queues, model_name, action_name, action_uid, data)
      return if data.empty?
      event = {
        application_name: Rails.application.class.parent_name.underscore,
        type:             "model",
        model_name:       model_name,
        action_name:      action_name,
        action_uid:       action_uid,
        date_time:        Time.now.utc,
        data:             data
      }
      @logger.info(event)
      @buffer.push_right(queues, event)
    end
  end
end

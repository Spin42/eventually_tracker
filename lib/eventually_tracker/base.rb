module EventuallyTracker
  class Base

    def initialize(logger, buffer, configuration)
      @logger         = logger
      @configuration  = configuration
      @buffer         = buffer
    end

    def track_action(queues, controller_name, action_name, response_code, action_uid, data, session_data)
      str =
      """Track controller action
      queues:\t\t#{queues}
      action_uid:\t#{action_uid}
      controller_name:\t#{controller_name}
      action_name:\t#{action_name}
      response_code:\t#{response_code}
      session_data:\t#{session_data}
      data:\t\t#{data}
      """
      @logger.info(str)
      @buffer.push_right(queues, {
        application_name: Rails.application.class.parent_name.underscore,
        type:             "controller",
        date_time:        Time.now.utc,
        controller_name:  controller_name,
        action_name:      action_name,
        action_uid:       action_uid,
        response_code:    response_code,
        data:             data,
        session_data:     session_data
      })
    end

    def track_change(queues, model_name, action_name, action_uid, data)
      str =
      """Track model change
      queues:\t\t#{queues}
      action_uid:\t#{action_uid}
      model_name:\t#{model_name}
      action_name:\t#{action_name}
      data:\t\t#{data}
      """
      if !data.empty?
        @logger.info(str)
        @buffer.push_right(queues, {
          application_name: Rails.application.class.parent_name.underscore,
          type:             "model",
          model_name:       model_name,
          action_name:      action_name,
          action_uid:       action_uid,
          date_time:        Time.now.utc,
          data:             data
        })
      end
    end
  end
end

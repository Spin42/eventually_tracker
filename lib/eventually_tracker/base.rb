module EventuallyTracker
  class Base

    def initialize(logger, buffer, configuration)
      @logger         = logger
      @configuration  = configuration
      @buffer         = buffer
    end

    def track_action(controller_name, action_name, action_uid, data, session_data)
      str =
      """Track controller action
      action_uid:\t#{action_uid}
      controller_name:\t#{controller_name}
      action_name:\t#{action_name}
      session_data:\t#{session_data}
      data:\t\t#{data}
      """
      @logger.info(str)
      @buffer.push_right({
        application_name: Rails.application.class.parent_name.underscore,
        type:             "controller",
        date_time:        Time.now.utc,
        controller_name:  controller_name,
        action_name:      action_name,
        action_uid:       action_uid,
        data:             data,
        session_data:     session_data
      })
    end

    def track_change(model_name, action_name, action_uid, data)
      str =
      """Track model change
      action_uid:\t#{action_uid}
      model_name:\t#{model_name}
      action_name:\t#{action_name}
      data:\t\t#{data}
      """
      if !data.empty?
        @logger.info(str)
        @buffer.push_right({
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

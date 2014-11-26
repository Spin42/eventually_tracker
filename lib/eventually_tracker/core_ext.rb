module EventuallyTracker
  ACTION_UID_METHOD_NAME = "eventually_action_uid"

  class CoreExt
    def self.extend_active_record_base(eventually_tracker)
      ActiveRecord::Base.class_eval do
        define_singleton_method :track_change do

          after_create do
            track_model_change(eventually_tracker, "create")
          end

          after_update do
            track_model_change(eventually_tracker, "update")
          end

          after_destroy do
            track_model_change(eventually_tracker, "destroy")
          end

          def track_model_change(eventually_tracker, action_name)
            model_name  = self.class.name.underscore
            data        = changes.except :created_at, :updated_at
            data        = { id: [id, nil] } if action_name == "destroy"
            action_uid  = send(ACTION_UID_METHOD_NAME) if defined?(ACTION_UID_METHOD_NAME)
            if EventuallyTracker.config.environments.include?(Rails.env)
              eventually_tracker.track_change model_name, action_name, action_uid, data
            end
          end
        end
      end
    end

    def self.extend_active_controller_base(eventually_tracker)
      ActionController::Base.class_eval do
        define_singleton_method :track_action do | options = {} |
          before_action do
            action_uid              = SecureRandom.hex
            @eventually_action_uid  = action_uid
            ActiveRecord::Base.send(:define_method, ACTION_UID_METHOD_NAME, proc { action_uid })
          end
          before_action options do
            controller_name = params[:controller]
            action_name     = params[:action]
            data            = params.except :controller, :action
            if EventuallyTracker.config.environments.include?(Rails.env)
              eventually_tracker.track_action controller_name, action_name, @eventually_action_uid, data
            end
          end
          after_action do
            ActiveRecord::Base.send(:remove_method, ACTION_UID_METHOD_NAME)
          end
        end
      end
    end
  end
end

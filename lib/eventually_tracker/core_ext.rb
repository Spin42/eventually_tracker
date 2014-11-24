module EventuallyTracker
  ACTION_UID_METHOD_NAME = "eventually_action_uid"

  class CoreExt
    def self.extend_active_record_base(eventually_tracker)
      ActiveRecord::Base.class_eval do
        define_singleton_method :track_change do
          before_save do
            action_uid              = SecureRandom.hex
            @eventually_action_uid  = action_uid
            ActiveRecord::Base.send(:define_method, ACTION_UID_METHOD_NAME, proc { action_uid })
          end
          after_save do
            model_name  = self.class.name.underscore
            created     = created_at == updated_at
            data        = changes.except :created_at, :updated_at
            action_uid  = send(ACTION_UID_METHOD_NAME)
            eventually_tracker.track_change model_name, created, action_uid, data
          end
          after_save do
            ActiveRecord::Base.send(:remove_method, ACTION_UID_METHOD_NAME)
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
            eventually_tracker.track_action controller_name, action_name, @eventually_action_uid, data
          end
          after_action do
            ActiveRecord::Base.send(:remove_method, ACTION_UID_METHOD_NAME)
          end
        end
      end
    end
  end
end

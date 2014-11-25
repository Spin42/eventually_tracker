module EventuallyTracker
  ACTION_UID_METHOD_NAME = "eventually_action_uid"

  class CoreExt
    def self.extend_active_record_base(eventually_tracker)
      ActiveRecord::Base.class_eval do
        define_singleton_method :track_change do
          before_save do
            define_action_uid
          end
          before_destroy do
            define_action_uid
          end
          after_save do
            track_model_change(eventually_tracker)
          end
          after_destroy do
            track_model_change(eventually_tracker, true)
          end
          after_save do
            remove_action_uid
          end
          after_destroy do
            remove_action_uid
          end

          def define_action_uid
            action_uid              = SecureRandom.hex
            @eventually_action_uid  = action_uid
            ActiveRecord::Base.send(:define_method, ACTION_UID_METHOD_NAME, proc { action_uid })
          end

          def remove_action_uid
            ActiveRecord::Base.send(:remove_method, ACTION_UID_METHOD_NAME)
          end

          def track_model_change(eventually_tracker, destroyed = false)
            model_name  = self.class.name.underscore
            action_name = :update
            action_name = :create  if created_at == updated_at
            action_name = :destroy if destroyed
            data        = changes.except :created_at, :updated_at
            data        = { id: [id, id] } if destroyed
            action_uid  = send(ACTION_UID_METHOD_NAME)
            eventually_tracker.track_change model_name, action_name, action_uid, data
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

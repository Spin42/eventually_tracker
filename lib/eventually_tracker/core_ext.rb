module EventuallyTracker
  class CoreExt

    ACTION_UID_METHOD_NAME = "eventually_tracker_action_uid"

    def self.extend_active_record_base_dummy
      ActiveRecord::Base.class_eval do
        define_singleton_method :track_change do | options = {} |
        end
      end
    end

    def self.extend_active_record_base(eventually_tracker)
      ActiveRecord::Base.class_eval do
        define_singleton_method :track_change do | options = {} |
          after_create do
            track_change eventually_tracker, :create
          end

          after_update do
            track_change eventually_tracker, :update
          end

          after_destroy do
            track_change eventually_tracker, :destroy
          end

          def track_change(eventually_tracker, action_name)
            model_name  = self.class.name.underscore
            data        = changes.except :created_at, :updated_at
            data        = { id: [id, nil] } if action_name == :destroy
            action_uid  = send(ACTION_UID_METHOD_NAME) if defined?(ACTION_UID_METHOD_NAME)
            eventually_tracker.track_change model_name, action_name, action_uid, data
          end
        end
      end
    end

    def self.extend_active_controller_base_dummy
      ActionController::Base.class_eval do
        define_singleton_method :track_action do | options = {} |
        end
      end
    end

    def self.extend_active_controller_base(eventually_tracker)
      ActionController::Base.class_eval do
        define_singleton_method :track_action do | options = {} |

          before_action options do
            EventuallyTracker::CoreExt.define_action_uid
          end

          before_action options do
            EventuallyTracker::CoreExt.track_action eventually_tracker, params, session
          end

          after_action options do
            EventuallyTracker::CoreExt.remove_action_uid
          end
        end
      end
    end

    private

    def self.define_action_uid
      action_uid              = SecureRandom.uuid
      @eventually_action_uid  = action_uid
      ActiveRecord::Base.send :define_method, ACTION_UID_METHOD_NAME, proc { action_uid }
    end

    def self.remove_action_uid
      ActiveRecord::Base.send :remove_method, ACTION_UID_METHOD_NAME
    end

    def self.track_action(eventually_tracker, params, session)
      session_data    = extract_tracked_session_keys EventuallyTracker.config.tracked_session_keys, session
      controller_name = params[:controller]
      action_name     = params[:action]
      data            = params.except :controller, :action
      eventually_tracker.track_action controller_name, action_name, @eventually_action_uid, data, session_data
    end

    def self.extract_tracked_session_keys(keys, session)
      keys.inject({}) do | hash, key |
        hash[key] = session[key]
        hash
      end
    end
  end
end

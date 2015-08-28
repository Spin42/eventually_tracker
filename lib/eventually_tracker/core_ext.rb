module EventuallyTracker
  class CoreExt
    ACTION_UID_METHOD_NAME        = "eventually_tracker_action_uid"
    REJECTED_ACTION_PARAMS_KEYS   = [:controller, :action]

    def self.extend_active_record_base_dummy
      ActiveRecord::Base.class_eval { define_singleton_method(:track_change) { ; } }
    end

    def self.extend_active_record_base(eventually_tracker)
      ActiveRecord::Base.class_eval do
        define_singleton_method(:track_change) do | options = {} |
          queues = options[:queues] || EventuallyTracker.config.queues
          after_create  { track_change(eventually_tracker, queues, :create, changes) }
          after_update  { track_change(eventually_tracker, queues, :update, changes) }
          after_destroy { track_change(eventually_tracker, queues, :destroy, "id": [id, nil]) }
        end

        def track_change(eventually_tracker, queues, action_name, changes)
          change      = {}
          change[:model_name]  = self.class.name.underscore
          change[:data]        = changes.except(:created_at, :updated_at)
          change[:action_uid]  = send(ACTION_UID_METHOD_NAME) if respond_to?(ACTION_UID_METHOD_NAME)
          change[:action_name] = action_name
          eventually_tracker.track_change(queues, change)
        end
      end
    end

    def self.extend_active_controller_base_dummy
      ActionController::Base.class_eval do
        define_singleton_method(:track_action) { ; }
      end
    end

    def self.extend_active_controller_base(eventually_tracker, logger)
      ActionController::Base.class_eval do
        define_singleton_method(:track_action) do | options = {} |
          queues = options[:queues] || EventuallyTracker.config.queues
          before_action(options) { define_action_uid }
          prepend_after_action(options) { track_action(eventually_tracker, queues, logger) }
          after_action(options)  { remove_action_uid }

          def define_action_uid
            action_uid              = SecureRandom.uuid
            @eventually_action_uid  = action_uid
            ActiveRecord::Base.send(:define_method, ACTION_UID_METHOD_NAME, proc { action_uid })
          end

          def remove_action_uid
            ActiveRecord::Base.send(:remove_method, ACTION_UID_METHOD_NAME)
          end

          def track_action(eventually_tracker, queues, logger)
            if EventuallyTracker::CoreExt.rejected_origin?(request)
              logger.warn "Origin user agent rejected: #{request.user_agent}"
              return
            end
            action            = {}
            action[:cookies_data]      = EventuallyTracker::CoreExt.extract_tracked_session_keys(session)
            action[:controller_name]   = params[:controller]
            action[:action_name]       = params[:action]
            action[:response_code]     = response.status
            action[:data]              = params.reject do |key, _value|
              REJECTED_ACTION_PARAMS_KEYS.include?(key)
            end
            action[:data][:user_agent] = request.user_agent
            action[:action_uid]        = @eventually_action_uid
            eventually_tracker.track_action(queues, action)
          end
        end
      end
    end

    def self.extract_tracked_session_keys(session)
      keys = EventuallyTracker.config.tracked_session_keys
      keys.each_with_object({}) do | key, hash |
        hash[key] = session[key]
      end
    end

    def self.rejected_origin?(request)
      rejected_user_agents  = Regexp.union(EventuallyTracker.config.rejected_user_agents)
      user_agent            = request.user_agent
      matching_user_agents  = user_agent.match(rejected_user_agents)
      !matching_user_agents.nil?
    end
  end
end

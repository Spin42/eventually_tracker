module EventuallyTracker
  class Configuration
    include ActiveSupport::Configurable
    config_accessor :queues
    config_accessor :redis_key_prefix
    config_accessor :redis_url
    config_accessor :remote_handlers
    config_accessor :local_handlers
    config_accessor :blocking_synchronize

    config_accessor :development_environments
    config_accessor :tracked_session_keys
    config_accessor :rejected_user_agents
    config_accessor :logger
  end
end

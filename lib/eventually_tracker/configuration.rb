module EventuallyTracker
  class Configuration
    include ActiveSupport::Configurable
    config_accessor :redis_key
    config_accessor :redis_url
    config_accessor :api_url
    config_accessor :api_secret
    config_accessor :api_key
    config_accessor :wait_events
    config_accessor :development_environments
    config_accessor :tracked_session_keys
  end
end

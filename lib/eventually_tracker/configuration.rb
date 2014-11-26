module EventuallyTracker
  class Configuration
    include ActiveSupport::Configurable
    config_accessor :redis_key
    config_accessor :redis_url
    config_accessor :api_url
    config_accessor :api_secret
    config_accessor :api_key
    config_accessor :blocking_pop
    config_accessor :environments
  end
end

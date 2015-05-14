require "eventually_tracker/version"
require "eventually_tracker/base"
require "eventually_tracker/logger"
require "eventually_tracker/configuration"
require "eventually_tracker/core_ext"
require "eventually_tracker/redis_buffer"
require "eventually_tracker/railtie" if defined?(Rails)

module EventuallyTracker

  def self.configure(&block)
    yield @configuration ||= EventuallyTracker::Configuration.new
  end

  def self.config
    @configuration
  end

  def self.logger
    @logger
  end

  def self.buffer
    @buffer
  end

  def self.init
    if @configuration.development_environments.include?(Rails.env)
      EventuallyTracker::CoreExt.extend_active_record_base_dummy
      EventuallyTracker::CoreExt.extend_active_controller_base_dummy
    else
      @logger             = EventuallyTracker::Logger.new
      @buffer             = EventuallyTracker::RedisBuffer.new(@logger, @configuration)
      eventually_tracker  = EventuallyTracker::Base.new(@logger, @buffer, @configuration)
      EventuallyTracker::CoreExt.extend_active_record_base(eventually_tracker)
      EventuallyTracker::CoreExt.extend_active_controller_base(eventually_tracker, @logger)
    end
  end

  configure do |config|
    config.redis_key                = "eventually_tracker"
    config.redis_url                = "redis://localhost:6379"
    config.api_url                  = "http://localhost:3000/api/events"
    config.api_secret               = "api_secret"
    config.api_key                  = "api_key"
    config.wait_events              = true
    config.event_handler            = nil
    config.development_environments = []
    config.tracked_session_keys     = []
    config.rejected_user_agents     = []
  end
end


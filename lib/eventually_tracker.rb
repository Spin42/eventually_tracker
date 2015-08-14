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
    @logger             = @configuration.logger || EventuallyTracker::Logger.new
    @buffer             = EventuallyTracker::RedisBuffer.new(@logger, @configuration)
    eventually_tracker  = EventuallyTracker::Base.new(@logger, @buffer, @configuration)

    if @configuration.development_environments.include?(Rails.env)
      EventuallyTracker::CoreExt.extend_active_record_base_dummy
      EventuallyTracker::CoreExt.extend_active_controller_base_dummy
    else
      EventuallyTracker::CoreExt.extend_active_record_base(eventually_tracker)
      EventuallyTracker::CoreExt.extend_active_controller_base(eventually_tracker, @logger)
    end
  end

  configure do |config|
    config.queues                   = [ "reporting", "gamification" ]
    config.redis_key_prefix         = "eventually_tracker"
    config.redis_url                = nil
    config.remote_handlers          = {}
    config.blocking_synchronize     = true
    config.local_handlers           = {}
    config.development_environments = []
    config.tracked_session_keys     = []
    config.rejected_user_agents     = []
    config.logger                   = nil
  end
end


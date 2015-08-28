require "logging"

module EventuallyTracker
  class Logger
    def initialize
      @logger ||= Logging.logger(STDOUT)
    end

    def debug(text)
      @logger.debug(text)
    end

    def info(text)
      @logger.info(text)
    end

    def warn(text)
      @logger.warn(text)
    end

    def error(text)
      @logger.error(text)
    end
  end
end

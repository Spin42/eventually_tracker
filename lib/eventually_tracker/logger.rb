require "logging"

module EventuallyTracker
  class Logger

    def initialize
      Logging.color_scheme("bright",
        :levels => {
          :info  => :green,
          :warn  => :yellow,
          :error => :red,
          :fatal => [:white, :on_red]
        },
        :date => :white,
        :logger => :cyan,
        :message => :white
      )
      Logging.appenders.stdout(
        "stdout",
        :layout => Logging.layouts.pattern(
          :pattern => "[%d] %-5l %c: %m\n",
          :color_scheme => "bright"
        )
      )
      @logger = Logging.logger["Eventually Tracker"]
      @logger.add_appenders "stdout"
    end

    def debug(text)
      @logger.debug text
    end

    def info(text)
      @logger.info text
    end

    def warn(text)
      @logger.warn text
    end

    def error(text)
      @logger.error text
    end
  end
end

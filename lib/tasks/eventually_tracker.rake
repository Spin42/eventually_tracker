require "rest-client"
require "base64"

namespace :eventually_tracker do

  def push_remote(event)
    uri        = EventuallyTracker.config.api_url
    api_key    = EventuallyTracker.config.api_key
    api_secret = EventuallyTracker.config.api_secret
    headers    = {
      content_type: :json,
      accept:       :json,
      api_key:      api_key,
      api_secret:   api_secret
    }
    EventuallyTracker.logger.debug("Publish event: #{event} to #{uri.to_s}.")
    RestClient.post(uri.to_s, event: event, headers)
  end

  def push_local(event)
    event_handler = EventuallyTracker.config.event_handler
    event_handler.handle_from_eventually_tracker(event)
    EventuallyTracker.logger.debug("Publish event: #{event} to event handler.")
  end

  task :synchronize, [ :push_type ] => :environment do | task, args |
    logger        = EventuallyTracker.logger
    buffer        = EventuallyTracker.buffer
    waiting_time  = 1
    push_type     = args.push_type

    while event = buffer.pop_left do
      begin
        if push_type == "remote"
          push_remote(event)
        else
          push_local(event)
        end
        logger.debug("Event published!")
        waiting_time = 1
      rescue => e
        logger.warn("Event not published, push it back and wait #{waiting_time} seconds.")
        logger.error("#{e}")
        buffer.push_left(event)
        sleep(waiting_time)
        waiting_time = [waiting_time * 2, 30].min
      ensure
        logger.debug("#{buffer.size} events are left.")
      end
    end
  end

end

require "rest-client"
require "base64"

namespace :eventually_tracker do
  task :synchronise => :environment do
    logger        = EventuallyTracker.logger
    buffer        = EventuallyTracker.buffer
    waiting_time  = 1
    while event = buffer.pop_left do
      begin
        uri        = EventuallyTracker.config.api_url
        api_key    = Base64.encode64 EventuallyTracker.config.api_key
        api_secret = Base64.encode64 EventuallyTracker.config.api_secret
        logger.debug "Publish event: #{event} to #{uri.to_s}."
        RestClient.post uri.to_s, {event: event}.to_json, api_key: api_key, api_secret: api_secret, content_type: "application/json", accept: :json
        logger.debug "Event published!"
        waiting_time = 1
      rescue => e
        logger.error "Event not published, push it back and wait #{waiting_time} seconds."
        logger.error "#{e}"
        buffer.push_left event
        sleep waiting_time
        waiting_time = [waiting_time * 2, 30].min
      ensure
        logger.debug "#{buffer.size} events are left."
      end
    end
  end
end

require "rest-client"
require "base64"

namespace :eventually_tracker do
  def push_remote(queue, event)
    remote_handlers = EventuallyTracker.config.remote_handlers
    remote_handler  = remote_handlers[queue.to_sym] || remote_handlers[queue.to_s]
    if remote_handler.nil?
      EventuallyTracker.logger.warn("Remote handler not found for queue #{queue}.")
      return
    end
    api_url = remote_handler[:api_url]
    headers = remote_handler_http_headers(remote_handler)
    EventuallyTracker.logger.debug("Publish event: #{event} to remote handler #{api_url}.")
    RestClient.post(api_url.to_s, { event: event }.to_json, headers)
  end

  def remote_handler_http_headers(remote_handler)
    api_key    = remote_handler[:api_key]
    api_secret = remote_handler[:api_secret]
    {
      content_type: :json,
      accept:       :json,
      api_key:      api_key,
      api_secret:   api_secret
    }
  end

  def push_local(queue, event)
    local_handlers = EventuallyTracker.config.local_handlers
    local_handler  = local_handlers[queue.to_sym] || local_handlers[queue.to_s]
    if local_handler
      local_handler.handle_from_eventually_tracker(event)
      EventuallyTracker.logger.debug("Publish event: #{event} to local handler.")
    else
      EventuallyTracker.logger.warn("Local handler not found for queue #{queue}.")
    end
  end

  task synchronize: :environment do
    queues = EventuallyTracker.config.queues
    queues.each do |queue|
      puts "Start sync queue #{queue}"
      Process.fork do
        synchronize(queue)
      end
    end
    Process.waitall
  end

  def synchronize(queue)
    logger        = EventuallyTracker.logger
    buffer        = EventuallyTracker.buffer
    waiting_time  = 1
    while event = buffer.pop_left(queue)
      begin
        sanitized_event = sanitize(event)
        push_remote(queue, sanitized_event)
        push_local(queue, sanitized_event)
        logger.debug("Event published!")
        waiting_time = 1
      rescue => e
        logger.warn("Event not published, push it back and wait #{waiting_time} seconds.")
        logger.error("#{e}")
        buffer.push_left([queue], event)
        sleep(waiting_time)
        waiting_time = [waiting_time * 2, 30].min
      ensure
        logger.debug("#{buffer.size(queue)} events are left.")
      end
    end
  end

  def sanitize(value)
    case value
    when Array
      value.map { |v| sanitize(v) }
    when Hash
      fitlered_value = {}
      value.each do |k, v|
        unless [:password, :password_confirmation].include?(k.to_sym)
          fitlered_value[k] = sanitize(v)
        end
      end
      fitlered_value
    else
      value
    end
  end
end

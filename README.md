# Eventually Tracker

Track all your controller events and model changes seamlessly and without code pollution.

## Requirements

* Redis

## Installation

Add this line to your application's Gemfile:

```ruby
gem "eventually_tracker", git: "https://github.com/Spin42/eventually_tracker.git"
```

And then execute:

    $ bundle

Add an initializer eventually_tracker.rb (those are example values).

```ruby
EventuallyTracker.configure do | config |
    # Queues where track_action and track_change will push events
    config.queues                   = [ "reporting" ]
    config.redis_key_prefix         = "eventually_tracker"       
    config.redis_url                = "redis://127.0.0.1:6379/1"
    config.remote_handlers          = {
      reporting: {
        api_url:    "http://127.0.0.1:7000/events",
        api_secret: "ApiSecret",
        api_key:    "ApiKey"
      }
    },
    # eventually_tracker:synchronize blocks when there is no event
    config.blocking_synchronize     = true  (default: true)
    config.local_handlers           = {}    (default: {})
    # List of the environments that are not tracked
    config.development_environments = []    (default: [])
    config.tracked_session_keys     = []    (default: [])
    config.rejected_user_agents     = []    (default: [])
    config.logger                   = nil   (default: internal logger)
 end
```

## Usage

Add `track_change` to the models that you want to track and the changes will be automatically stored in `config.queues`.

```ruby
class Message < ActiveRecord::Base
  track_change
end
```

Add `track_action` to the controllers that you want to track and the actions will be automatically stored in `config.queues`.

```ruby
class MessagesController < ApplicationController
  track_action only: [:index]

  def index
  end
end
```

Run `rake eventually_tracker:synchronize` to flush the events stored in redis and send them to the `config.remote_handlers` specified in `config.queues`.

## Event types

### Model

```json
{
  "application_name": "my_rails_app",
  "type":             "model",
  "date_time":        "2014-11-22T14:12:08.377Z",
  "model_name":       "message",
  "action_name":      "update",
  "action_uid":       "de447856a6200d2c7ca5432b29833ef6",
  "data": {
    "text": [
      "First title",
      "First title NEW"
    ],
    "author": [
      "Description\r\n",
      "Description NEW\r\n"
    ]
  }
}
```

### Controller

```json
{
  "application_name": "my_rails_app",
  "type":             "controller",
  "date_time":        "2014-11-22T14:10:28.897Z",
  "controller_name":  "messages",
  "action_name":      "index",
  "action_uid":       "464a09594d23174dc59a35e2c7f016a6",
  "data":             { },
  "session_data":     { }
}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/eventually_tracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

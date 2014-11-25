# EventuallyTracker

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

## Usage

Add an initializer eventually_tracker.rb.

```ruby
EventuallyTracker.configure do | config |
    config.redis_key    = "eventually_tracker"
    config.redis_url    = "redis://localhost:6379"
    config.api_url      = "http://localhost:3000/api/events"
    config.api_secret   = "api_secret"
    config.api_key      = "api_key"
    config.blocking_pop = true
 end
```

Create a controller that respond to POST `config.api_url` to handle the event.

```ruby
require "base64"

class Api::EventsController < APIController
  before_action :authenticate

  def create
    event = params["event"]
    # Handle event data
  end

  private
  def authenticate
    api_key     = Base64.decode64 params["api_key"]
    api_secret  = Base64.decode64 params["api_secret"]
    unless api_key == "api_key" && api_secret == "api_secret"
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end
end
```

Add `track_change` to the models that you want to track.

```ruby
class Message < ActiveRecord::Base
  track_change
end
```

Add `track_action` to the controllers that you want to track.

```ruby
class MessagesController < ApplicationController
  track_action only: [:index]

  def index
  end
end
```

Run `rake eventually_tracker:synchronise` to flush the events stored in redis and send them to the `config.api_url`.

## Event

### Model

```json
{
  "type": "model",
  "model_name": "message",
  "created": "false",
  "action_uid": "de447856a6200d2c7ca5432b29833ef6",
  "date_time": "2014-11-22T14:12:08.377Z",
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
  "type": "controller",
  "date_time": "2014-11-22T14:10:28.897Z",
  "controller_name": "messages",
  "action_name": "index",
  "action_uid": "464a09594d23174dc59a35e2c7f016a6",
  "data": {
    "query": "query parameters"
  }
}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/eventually_tracker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

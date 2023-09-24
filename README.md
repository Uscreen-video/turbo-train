![Build Status](https://github.com/Uscreen-video/turbo-train/actions/workflows/main.yml/badge.svg)

# Turbo::Train

<img align="right" width="220" title="Turbo::Train logo"
     src="https://user-images.githubusercontent.com/3010927/210603861-4b265489-a4a7-4d2a-bceb-40ceccebcd96.jpg">


Real-time page updates for your Rails app over SSE with [Mercure](https://mercure.rocks) or [Fanout Cloud](https://fanout.io/cloud) and [Hotwire Turbo](https://turbo.hotwired.dev/handbook/streams#integration-with-server-side-frameworks).

* **Uses [SSE](https://html.spec.whatwg.org/multipage/server-sent-events.html)**. No more websockets, client libraries, JS code and handling reconnects. Just an HTTP connection. Let the [browser](https://caniuse.com/eventsource) do the work.
* **Seamless Hotwire integration.** Use it exactly like [ActionCable](https://github.com/hotwired/turbo-rails#come-alive-with-turbo-streams). Drop-in replacement for `broadcast_action_to` and usual helpers.
* **Simple.** Get running in minutes, scale easily in production 🚀

## Before your proceed

Using this gem requires some knowledge of ActionCable and broadcasting turbo streams. Turbo::Train is designed to mimic those, so it is highly recommended to first try the original to understand the concept.

You can start [here](https://hotwired.dev/) and proceed with the [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction). One of its chapters will be covering [Turbo Streams](https://turbo.hotwired.dev/handbook/streams). Specifically [this section](https://turbo.hotwired.dev/handbook/streams#integration-with-server-side-frameworks) would be the main prerequisite to understanding what this gem is about: it covers [Broadcastable](https://github.com/hotwired/turbo-rails/blob/main/app/models/concerns/turbo/broadcastable.rb) and the overall idea of working with Mercure or Fanout Cloud.

## Prerequisites

1. Rails 7+
2. Mercure server (setup instructions below)

This should also work for Rails 6, but you will also need to install [turbo-rails](https://github.com/hotwired/turbo-rails#installation) manually before this gem.

## Installation

### Step 1. Turbo::Train

Instructions for Rails 7+

1. Add the turbo-train gem to your Gemfile: `gem 'turbo-train'`
2. Run `bundle install`
3. Run `rails turbo_train:install`

Instructions for Rails 6

1. Install [turbo-rails](https://github.com/hotwired/turbo-rails#installation)
2. Repeat steps for Rails 7 above

### Step 2. Server
#### Mercure

Mercure is installed as a plugin to [Caddy](https://github.com/caddyserver/caddy) server. For mac users everything is pretty easy:

```
brew install caddy
```

```
caddy add-package github.com/dunglas/mercure/caddy
```

Now you are ready to run 🚀

```
caddy run
```
#### Fanout Cloud

We only support the cloud version today. To use [Fanout](https://fanout.io/cloud/) you must purchase a paid account with a contract for Fastly's services.

#### Fanout self-hosted (Pushpin)

Coming soon.
## Usage

If you are familiar with broadcasting from ActionCable, usage would be extremely familiar:

```erb
<%# app/views/chat_messages/index.html.erb %>
<%= turbo_train_from "chat_messages" %>

<div id="append_new_messages_here"></div>
```

And then you can send portions of HTML from your Rails backend to deliver live to all currently open browsers:

```ruby
Turbo::Train.broadcast_action_to(
  'chat_messages',
  action: :append,
  target:'append_new_messages_here',
  html: '<span>Test!</span>'
)
```

or in real world you'd probably have something like

```ruby
# app/models/chat_message.rb
after_create_commit do
  Turbo::Train.broadcast_action_to(
    'chat_messages',
    action: :append,
    target: 'append_new_messages_here',
    partial: 'somepath/message'
  )
end
```

You have the same options as original Rails Turbo helpers: rendering partials, pure html, [same actions](https://turbo.hotwired.dev/reference/streams).

## Configuration

To specify different Mercure or Fanout server settings, please adjust the generated `config/initializers/turbo_train.rb` file:

```ruby
Turbo::Train.configure do |config|
  config.skip_ssl_verification = true # Development only; don't do this in production
  config.default_server = :fanout # Default value is :mercure

  config.server :mercure do |mercure|
    mercure.mercure_domain = ...
    mercure.publisher_key = ...
    mercure.subscriber_key = ...
  end

  config.server :fanout do |fanout|
    fanout.service_url = ...
    fanout.service_id = ...
    fanout.fastly_key = ...
  end
end
```

### Mercure

* Your SSE will connect to `https://#{configuration.mercure_domain}/.well-known`.
* The publisher/subscriber key correspond to the [configuration](https://mercure.rocks/docs/hub/config) or your Mercure server.

By default, these are set to `localhost`/`test`/`testing` to match the configuration of the local development server from the installation instructions above.

***

<img width="80" title="Turbo::Train logo"
     src="https://user-images.githubusercontent.com/3010927/210604381-4b715322-55f8-4db8-8bb8-660be734704d.jpg">

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

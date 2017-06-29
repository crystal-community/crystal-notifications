# notifications

A library for notifications, this started as a port from ActiveSupport::Notifications

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  notifications:
    github: benoist/notifications
```

## Usage

```crystal
require "notifications"

called = 0

# Subscribe to some event
Notifications.subscribe "some.event" do |event|
  called += 1
end

# Subscribe other event
Notifications.subscribe "other.event" do |event|
  called += 1
end

# Subscribe same event
Notifications.subscribe "other.event" do |event|
  called += 1
end

Notifications.instrument "some.event"
Notifications.instrument "other.event"

puts called
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/[your-github-name]/notifications/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) Benoist Claassen - creator, maintainer

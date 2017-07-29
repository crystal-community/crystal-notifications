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

### DB::LogSubscriber

Do you want debug info for the crystal-db shard?

Create a log subscriber

```crystal
require "notifications/subscribers/db_log_subscriber"

Notifications::LogSubscriber.logger = Logger.new(STDOUT).tap do |logger|
  logger.level = Logger::Severity::DEBUG
  logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
    io << message
  end
end
```

This will now print the following lines to `STDOUT`

```
  SQL (361.0µs)  create table if not exists a (i int not null, str text not null);
  SQL (51.0µs)  SELECT i, str FROM a WHERE i = ?
```

## Contributing

1. Fork it ( https://github.com/[your-github-name]/notifications/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) Benoist Claassen - creator, maintainer

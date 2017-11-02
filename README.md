# notifications

A library for notifications, this started as a port from ActiveSupport::Notifications

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  notifications:
    github: crystal-community/crystal-notifications
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

This will now print the following lines to `STDOUT` when queries have been executed

```
  SQL (361.0µs)  create table if not exists a (i int not null, str text not null);
  SQL (51.0µs)  SELECT i, str FROM a WHERE i = ?
```

### Kemal::LogSubscriber with DB::LogSubscriber

```crystal
require "kemal"
require "sqlite3"
require "db"
require "notifications"
require "notifications/subscribers/kemal_log_subscriber"
require "notifications/subscribers/db_log_subscriber"

Notifications::LogSubscriber.logger = Logger.new(STDOUT).tap do |logger|
  logger.level = Logger::Severity::DEBUG
end

get "/" do
  ::DB.open "sqlite3::memory:" do |db|
    db.exec %(create table if not exists a (i int not null, str text not null);)
    db.query("SELECT i, str FROM a WHERE i = ?", 23)
  end

  render "examples/template.ecr"
end

Kemal.config do |config|
  config.logging = false
end

Kemal.run

```

This will output the following:

```
I, [2017-07-29 23:57:02 +0200 #69971]  INFO -- : Processing by GET /?test=value
I, [2017-07-29 23:57:02 +0200 #69971]  INFO -- :   Parameters url: {} query: {"test" => ["value"]} body: {}
D, [2017-07-29 23:57:02 +0200 #69971] DEBUG -- :   SQL (642.0µs)  create table if not exists a (i int not null, str text not null);
D, [2017-07-29 23:57:02 +0200 #69971] DEBUG -- :   SQL (41.0µs)  SELECT i, str FROM a WHERE i = ?
I, [2017-07-29 23:57:02 +0200 #69971]  INFO -- :   Rendered examples/template.ecr (6.0µs)
I, [2017-07-29 23:57:02 +0200 #69971]  INFO -- : Completed 200 in 1.85ms
```

## Contributing

1. Fork it ( https://github.com/benoist/notifications/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [benoist](https://github.com/benoist) Benoist Claassen - creator, maintainer

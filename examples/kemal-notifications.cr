require "kemal"
require "sqlite3"
require "db"
require "../src/notifications"
require "../src/notifications/subscribers/kemal_log_subscriber"
require "../src/notifications/subscribers/db_log_subscriber"

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

Kemal.run do |config|
  config.logging = false #currently broken it will always log
end

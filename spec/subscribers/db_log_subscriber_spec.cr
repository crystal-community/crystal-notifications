require "sqlite3"
require "../spec_helper"
require "../../src/notifications/subscribers/db_log_subscriber"

module NotificationsTest
  describe ::DB::LogSubscriber do
    it "ensures statements are closed" do
      log = IO::Memory.new

      Notifications::LogSubscriber.logger = Logger.new(log).tap do |logger|
        logger.level = Logger::Severity::DEBUG
        logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
          io << message
        end
      end

      ::DB.open "sqlite3::memory:" do |db|
        db.exec %(create table if not exists a (i int not null, str text not null);)
        db.query("SELECT i, str FROM a WHERE i = ?", 23)
      end

      log.to_s.includes?("create table if not exists a (i int not null, str text not null)").should eq true
      log.to_s.includes?("SELECT i, str FROM a WHERE i = ?").should eq true
    end
  end
end

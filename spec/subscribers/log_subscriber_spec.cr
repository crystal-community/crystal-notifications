require "../spec_helper"
require "../../src/notifications/subscribers/log_subscriber"

module NotificationsTest
  class MyLogSubscriber < Notifications::LogSubscriber
    getter event : Event?

    def some_event(event)
      @event = event
      info event.name
    end

    def foo(event)
      debug "debug"
      info { "info" }
      warn "warn"
    end

    def bar(event)
      info "#{"cool".colorize(:red)}, #{"isn't it?".colorize(:blue).mode(:bold)}"
    end

    def puke(event)
      raise "puke"
    end
  end

  MyLogSubscriber.attach_to(:namespace)

  describe MyLogSubscriber do
    it "logs with colors" do
      log = IO::Memory.new
      Notifications::LogSubscriber.logger = Logger.new(log).tap do |logger|
        logger.level = Logger::Severity::DEBUG
        logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
          io << message
        end
      end
      Notifications.instrument("bar.namespace", Notifications::Payload.new)

      log.to_s.should eq "\e[31mcool\e[0m, \e[34;1misn't it?\e[0m\n"
    end

    it "loggs" do
      log = IO::Memory.new
      Notifications::LogSubscriber.logger = Logger.new(log).tap do |logger|
        logger.level = Logger::Severity::DEBUG
        logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
          io << message
        end
      end
      Notifications.instrument("foo.namespace", Notifications::Payload.new)

      log.to_s.should eq "debug\ninfo\nwarn\n"
    end
  end
end

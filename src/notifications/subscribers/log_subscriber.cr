require "../subscriber"
require "logger"
require "colorize"

module Notifications
  class LogSubscriber < Subscriber
    @@logger : Logger?

    def self.logger
      @@logger ||= Logger.new(STDOUT)
    end

    def self.logger=(logger)
      @@logger = logger
    end

    def self.log_subscribers
      subscribers
    end

    def logger
      Notifications::LogSubscriber.logger
    end

    def start(name, id, payload)
      super if logger
    end

    def finish(name, id, payload)
      super if logger
    rescue e : Exception
      logger.error "Could not log #{name.inspect} event. #{e.class}: #{e.message} #{e.backtrace}"
    end

    {% for level in ["info", "debug", "warn", "error", "fatal", "unknown"] %}
      protected def {{level.id}}
        logger.{{level.id}}(yield) if logger
      end

      protected def {{level.id}}(progname = nil)
        logger.{{level.id}}(progname) if logger
      end
    {% end %}
  end
end

module Notifications
  class Fanout
    include Notifier

    def initialize
      @subscribers = [] of (Subscribers::Evented | Subscribers::Timed)
      @listeners_for = {} of String => Array(Subscribers::Evented | Subscribers::Timed)
      super
    end

    def subscribe(pattern, subscriber : Subscriber | Listener)
      subscriber = Subscribers.new pattern, subscriber
      @subscribers << subscriber
      @listeners_for.clear
      subscriber
    end

    def subscribe(pattern = nil, &block : Event ->)
      subscribe(pattern, block)
    end

    def subscribe(pattern, block : Event ->)
      subscriber = Subscribers.new pattern, ProcListener.new(block)
      @subscribers << subscriber
      @listeners_for.clear
      subscriber
    end

    def unsubscribe(subscriber_or_name)
      case subscriber_or_name
      when String
        @subscribers.reject! { |s| s.matches?(subscriber_or_name) }
      else
        @subscribers.delete(subscriber_or_name)
      end

      @listeners_for.clear
    end

    def start(name, id, payload)
      listeners_for(name).each { |s| s.start(name, id, payload) }
    end

    def finish(name, id, payload)
      listeners_for(name).each { |s| s.finish(name, id, payload) }
    end

    def publish(name, started, finish, id, payload)
      listeners_for(name).each { |s| s.publish(name, started, finish, id, payload) }
    end

    def listeners_for(name)
      @listeners_for[name] ||= @subscribers.select { |s| s.subscribed_to?(name) }
    end

    def listening?(name)
      listeners_for(name).any?
    end

    def wait
      Fiber.yield
    end

    module Subscribers # :nodoc:
      def self.new(pattern : String?, listener : Listener | Subscriber)
        if listener.responds_to?(:start) && listener.responds_to?(:finish)
          Evented.new pattern, listener
        elsif listener.responds_to?(:call)
          Timed.new pattern, listener
        else
          raise "Invalid listener"
        end
      end

      class Evented # :nodoc:
        def initialize(@pattern : String?, @delegate : Listener | Subscriber)
        end

        def publish(name, started, finish, id, payload)
          delegate = @delegate
          delegate.publish(name, started, finish, id, payload) if delegate.responds_to?(:publish)
        end

        def start(name, id, payload)
          delegate = @delegate
          delegate.start name, id, payload if delegate.responds_to?(:start)
        end

        def finish(name, id, payload)
          delegate = @delegate
          delegate.finish name, id, payload if delegate.responds_to?(:finish)
        end

        def subscribed_to?(name)
          @pattern === name || @pattern == nil
        end

        def matches?(name)
          @pattern && @pattern === name
        end
      end

      class Timed < Evented
        def self.timestack
          @@timestack ||= Hash(Fiber, Array(Time)).new { |h, k| h[k] = [] of Time }
        end

        def publish(name, started, finish, id, payload)
          @delegate.call Event.new(name, started, Time.now, id, payload)
        end

        def start(name, id, payload)
          Timed.timestack[Fiber.current].push Time.now
        end

        def finish(name, id, payload)
          started = Timed.timestack[Fiber.current].pop
          delegate = @delegate
          case delegate
          when TimedListener
            delegate.call Event.new(name, started, Time.now, id, payload)
          else
            raise InvalidListener.new(delegate)
          end
        end
      end
    end
  end
end

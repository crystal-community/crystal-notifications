require "random/secure"
require "./notifications/listeners"
require "./notifications/notifier"
require "./notifications/fanout"
require "./notifications/event"
require "./notifications/instrumenter"
require "./notifications/subscriber"

module Notifications
  NOTIFIER     = Fanout.new
  INSTRUMENTER = Instrumenter.new(NOTIFIER)

  alias PayloadValue = String | Int64 | Int32 | Float64 | Bool | Exception
  alias Payload = Hash(String, PayloadValue)

  def self.notifier
    NOTIFIER
  end

  def self.instrumenter
    INSTRUMENTER
  end

  def self.publish(name, started, finish, id, payload)
    notifier.publish(name, started, finish, id, payload)
  end

  def self.instrument(name, payload = Payload.new)
    if notifier.listening?(name)
      instrumenter.instrument(name, payload) { yield payload }
    else
      yield payload
    end
  end

  def self.instrument(name, payload = Payload.new)
    if notifier.listening?(name)
      instrumenter.instrument(name, payload) { }
    end
  end

  def self.subscribe(subscriber : Subscriber | Event ->)
    notifier.subscribe(nil, subscriber)
  end

  def self.subscribe(&block : Event ->)
    notifier.subscribe(nil, block)
  end

  def self.subscribe(pattern, subscriber : Subscriber)
    notifier.subscribe(pattern, subscriber)
  end

  def self.subscribe(pattern, callback : Event ->)
    notifier.subscribe(pattern, callback)
  end

  def self.subscribe(pattern, &block : Event ->)
    notifier.subscribe(pattern, block)
  end

  def self.subscribed(callback, name, &block)
    subscriber = subscribe(name, callback)
    yield
  ensure
    unsubscribe(subscriber)
  end

  def self.unsubscribe(subscriber_or_name)
    notifier.unsubscribe(subscriber_or_name)
  end
end

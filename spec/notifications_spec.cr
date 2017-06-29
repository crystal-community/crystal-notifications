require "./spec_helper"

module NotificationsTest
  describe Notifications do
    it "tests subscribed" do
      name = "foo"
      name2 = name * 2
      expected = [name, name]

      events = [] of String
      callback = ->(event : Event) { events << event.name }
      Notifications.subscribed(callback, name) do
        Notifications.instrument(name)
        Notifications.instrument(name2)
        Notifications.instrument(name)
      end
      events.should eq expected

      Notifications.instrument(name)
      events.should eq expected
    end

    it "removes a subscription when unsubscribing" do
      notifier = Notifications::Fanout.new
      events = [] of String
      subscription = notifier.subscribe do |event|
        events << event.name
      end
      notifier.publish "name", Time.now, Time.now, "id", Notifications::Payload.new
      notifier.wait
      events.should eq ["name"]
      notifier.unsubscribe(subscription)
      notifier.publish "name", Time.now, Time.now, "id", Notifications::Payload.new
      notifier.wait
      events.should eq ["name"]
    end

    it "removes a subscription when unsubscribing with name" do
      notifier = Notifications::Fanout.new
      named_events = [] of String
      subscription = notifier.subscribe "named.subscription" do |event|
        named_events << event.name
      end
      notifier.publish "named.subscription", Time.now, Time.now, "id", Notifications::Payload.new
      notifier.wait
      named_events.should eq ["named.subscription"]
      notifier.unsubscribe("named.subscription")
      notifier.publish "named.subscription", Time.now, Time.now, "id", Notifications::Payload.new
      notifier.wait
      named_events.should eq ["named.subscription"]
    end

    it "leaves the other subscriptions when unsubscribing by name " do
      notifier = Notifications::Fanout.new
      events = [] of String
      named_events = [] of String
      subscription = notifier.subscribe "named.subscription" do |event|
        named_events << event.name
      end
      subscription = notifier.subscribe do |event|
        events << event.name
      end
      notifier.publish "named.subscription", Time.now, Time.now, "id", Notifications::Payload.new
      notifier.wait
      events.should eq ["named.subscription"]
      notifier.unsubscribe("named.subscription")
      notifier.publish "named.subscription", Time.now, Time.now, "id", Notifications::Payload.new
      notifier.wait
      events.should eq ["named.subscription", "named.subscription"]
    end

    it "returns the block result" do
      Notifications.instrument("name") { 1 + 1 }.should eq 2
    end

    it "exposes an id method" do
      Notifications.instrumenter.id.size.should eq 20
    end

    it "allows nested events" do
      Notifications.notifier = Notifications::Fanout.new
      events = [] of String
      Notifications.notifier.subscribe do |event|
        events << event.name
      end

      Notifications.instrument("outer") do
        Notifications.instrument("inner") do
          1 + 1
        end
        events.size.should eq 1
        events.first.should eq "inner"
      end

      events.size.should eq 2
      events.last.should eq "outer"
    end

    it "publishes when exceptions are raised" do
      Notifications.notifier = Notifications::Fanout.new
      events = [] of String
      Notifications.notifier.subscribe do |event|
        events << event.name
      end

      begin
        Notifications.instrument("raises") do
          raise "FAIL"
        end
      rescue e : Exception
        e.message.should eq "FAIL"
      end

      events.size.should eq 1
    end

    it "publishes when instrumented without a block" do
      Notifications.notifier = Notifications::Fanout.new
      events = [] of String
      Notifications.notifier.subscribe do |event|
        events << event.name
      end

      Notifications.instrument("no block")

      events.size.should eq 1
      events.first.should eq "no block"
    end

    it "publishes events with details" do
      Notifications.notifier = Notifications::Fanout.new
      events = [] of Event
      Notifications.notifier.subscribe do |event|
        events << event
      end

      Notifications.instrument("outer", Notifications::Payload.new.tap { |p| p.message = "test" }) do
        Notifications.instrument("inner")
      end

      events.first.name.should eq "inner"
      events.last.payload.message.should eq "test"
    end
  end
end

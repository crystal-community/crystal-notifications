require "../src/notifications"

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

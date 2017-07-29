require "../src/notifications"

Notifications.subscribe do |event|
  pp event
end

Notifications.instrument "outer" do
  Notifications.instrument "inner"
end

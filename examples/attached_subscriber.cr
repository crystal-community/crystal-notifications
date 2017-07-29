require "../src/notifications"

class MySubscriber < Notifications::Subscriber
  def some_event(event)
    pp event #contains the inner event in children
  end

  def inner(event)
    pp event
  end

  attach_to(:namespace)
  attach_to(:other_namespace)
end

Notifications.instrument "some_event.namespace" do
  Notifications.instrument "inner.other_namespace"
end

module Notifications
  module Notifier
    abstract def start(name, id, payload)
    abstract def finish(name, id, payload)
  end
end

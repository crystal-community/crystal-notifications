module Notifications
  class InvalidListener < Exception
    def initialize(delegate)
      @message = "Invalid listener #{delegate}"
    end
  end

  module EventedListener
    abstract def start(name, id, payload)
    abstract def finish(name, id, payload)
  end

  module TimedListener
    abstract def call(event : Event)
  end

  class ProcListener
    include TimedListener

    def initialize(@proc : Proc(Event, Nil))
    end

    def call(event : Event)
      @proc.call(event)
    end
  end

  alias Listener = EventedListener | TimedListener
end

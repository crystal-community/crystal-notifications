module Notifications
  class Subscriber
    macro attach_to(namespace)
      subscriber = {{@type}}.new
      {% for event in @type.methods %}
        {% if event.visibility == :public && event.args.first && event.args.size == 1 %}
          pattern = "{{event.name}}.{{namespace.id}}"
          subscriber.callers[pattern] = ->(e : Event) { subscriber.{{event.name}}(e) }
          Notifications.subscribe(pattern, subscriber)
        {% end %}
      {% end %}
    end

    getter :patterns # :nodoc:
    @queue_key : String

    def initialize
      @queue_key = [self.class.name, object_id].join "-"
      @patterns = [] of String
    end

    def callers
      @callers ||= {} of String => Event ->
    end

    def start(name, id, payload)
      e = Event.new(name, Time.now, Time.now, id, payload)

      if event_stack.any?
        parent = event_stack.last
        parent << e
      end

      event_stack.push e
    end

    def finish(name, id, payload)
      finished = Time.now
      event = event_stack.pop
      event.end_time = finished
      event.payload = payload

      callers[name].call(event) if callers.has_key?(name)
    end

    def call(event : Event)
      raise "subscribers cannot respond to all messages"
    end

    private def event_stack
      @event_stack ||= [] of Event
    end
  end
end

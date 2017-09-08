require "./log_subscriber"
require "kemal"

macro render(filename)
  Notifications.instrument("render.kemal", Notifications::Payload{"name" => {{filename}}}) do
    Kilt.render({{filename}})
  end
end

module Kemal
  class InstrumentHandler
    include HTTP::Handler
    INSTANCE = new

    def call(context)
      Notifications.instrument("start_processing.kemal", Notifications::Payload{
        "method" => context.request.method,
        "resource" => context.request.resource,
        "query_params" => context.params.query.raw_params.inspect,
        "url_params" => context.params.url.inspect,
        "body_params" => context.params.body.raw_params.inspect,
      })
      Notifications.instrument("process.kemal") do |payload|
        call_next(context).tap do
          payload["status_code"] = context.response.status_code
          payload["method"] = context.request.method
          payload["resource"] = context.request.resource
        end
      end
    end
  end
end

add_handler Kemal::InstrumentHandler.new

module Kemal
  class LogSubscriber < Notifications::LogSubscriber
    def render(event)
      message = String::Builder.build do |message|
        message << "  Rendered #{event.payload["name"]}"
        message << " (#{event.duration_text})"
      end
      info message
    end

    def start_processing(event)
      info "Processing by #{event.payload["method"]} #{event.payload["resource"]}"
      info "  Parameters url: #{event.payload["url_params"]?} query: #{event.payload["query_params"]?} body: #{event.payload["body_params"]?}"
    end

    def process(event)
      message = String::Builder.build do |message|
        message << "Completed #{event.payload["status_code"]} in #{event.duration_text}"
      end
      info message
    end

    attach_to(:kemal)
  end
end

require "./log_subscriber"
require "db"

module DB
  class LogSubscriber < Notifications::LogSubscriber
    def sql(event)
      payload = event.payload

      name = "#{payload["name"]} (#{event.duration_text})"

      sql = payload["sql"]
      binds = nil

      name = colorize_payload_name(name, payload["name"])
      sql = sql.colorize(sql_color(sql)).mode(:bold)

      debug "  #{name}  #{sql}#{binds}"
    end

    private def colorize_payload_name(name, payload_name)
      if payload_name == "" || payload_name == "SQL" # SQL vs Model Load/Exists
        name.colorize(:magenta).mode(:bold)
      else
        name.colorize(:cyan).mode(:bold)
      end
    end

    private def sql_color(sql)
      case sql
      when /\A\s*rollback/mi
        :red
      when /select .*for update/mi, /\A\s*lock/mi
        :white
      when /\A\s*select/i
        :blue
      when /\A\s*insert/i
        :green
      when /\A\s*update/i
        :yellow
      when /\A\s*delete/i
        :red
      when /transaction\s*\Z/i
        :cyan
      else
        :magenta
      end
    end
    attach_to(:db)
  end

  module QueryMethods
    def query(query, *args)
      Notifications.instrument("sql.db", Notifications::Payload{"sql" => query, "name" => "SQL"}) do
        previous_def
      end
    end

    def exec(query, *args)
      Notifications.instrument("sql.db", Notifications::Payload{"sql" => query, "name" => "SQL"}) do
        previous_def
      end
    end

    # Performs the `query` and returns a single scalar value
    # puts db.scalar("SELECT MAX(name)").as(String) # => (a String)
    def scalar(query, *args)
      Notifications.instrument("sql.db", Notifications::Payload{"sql" => query, "name" => "SQL"}) do
        previous_def
      end
    end
  end
end

module Notifications
  class Payload
    property exception : Exception?
    property message : String?

    def ==(other : Payload)
      exception == other.exception &&
        message == other.message
    end
  end
end

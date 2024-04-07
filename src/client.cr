require "http/web_socket"
require "json"
require "log"

module DiscordMusic
  struct Event
    include JSON::Serializable

    @[JSON::Field(key: "op")]
    getter opcode : Int64

    @[JSON::Field(key: "s")]
    getter sequence : Int64?

    @[JSON::Field(key: "d")]
    getter data : JSON::Any

    @[JSON::Field(key: "t")]
    getter event_type : String?
  end

  class Client
    Log = ::Log.for("client")

    @ws : HTTP::WebSocket
    @events_handler = {} of Int64 => Event ->

    def initialize(uri : URI)
      @ws = HTTP::WebSocket.new(uri)
    end

    def close
      Log.info { "closing connection" }
      @ws.close
    end

    def send(message : String)
      @ws.send(message)
    end

    def on(opcode : Int64, &handler : Event ->)
      @events_handler[opcode] = handler
    end

    def run
      Log.info { "starting websocket" }

      @ws.on_message do |message|
        payload = Event.from_json(message)

        Log.info { "received new message: #{payload}" }

        if @events_handler[payload.opcode]?
          @events_handler[payload.opcode].call(payload)
        else
          Log.error { "handler not found for opcode=#{payload.opcode}" }
        end
      end

      @ws.run
    end
  end
end

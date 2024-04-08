require "http/web_socket"
require "json"
require "log"

module DiscordMusic
  # The struct `Event` represents the structure of an
  # [gateway event](https://discord.com/developers/docs/topics/gateway-events) received from Discord.
  # It includes the opcode, sequence, data, and event type.
  #
  # More info [here](https://discord.com/developers/docs/topics/gateway-events#payload-structure)
  struct Event
    include JSON::Serializable

    module DataConverter
      def self.from_json(parser)
        data = IO::Memory.new
        JSON.build(data) { |builder| parser.read_raw(builder) }
        data.rewind
      end

      def self.to_json(value, builder)
        builder.raw(value.to_s)
      end
    end

    @[JSON::Field(key: "op")]
    getter opcode : Int64

    @[JSON::Field(key: "s")]
    getter? sequence : Int64?

    @[JSON::Field(key: "d", converter: DiscordMusic::Event::DataConverter)]
    getter data : IO::Memory

    @[JSON::Field(key: "t")]
    getter? event_type : String?

    # Custom inspect method for better debugging and logging.
    def inspect(io : IO)
      io << "Event(@opcode="
      io << opcode
      io << " @sequence="
      io << sequence?
      io << " @event_type="
      io << event_type?
      io << " @data="
      io << data.to_s[0..30]
      io << "...}"
      io << ')'
    end
  end

  class Client
    Log = ::Log.for("client")

    @ws : HTTP::WebSocket

    def initialize(uri : URI)
      @ws = HTTP::WebSocket.new(uri)
      @ws.on_close { Log.info { "Websocket connection closed" } }
    end

    def on_message(&handler : Event ->)
      @ws.on_message do |message|
        payload = Event.from_json(message)
        handler.call(payload)
      end
    end

    def close
      @ws.close
    end

    def send(message : String)
      @ws.send(message)
    end

    def run
      Log.info { "Starting websocket" }
      @ws.run
    end
  end
end

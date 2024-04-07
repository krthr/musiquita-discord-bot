require "./client.cr"
require "./constants.cr"
require "./events.cr"
require "./mapping/*"

module DiscordMusic
  WS_BASE_URL = "wss://gateway.discord.gg/?v=10&encoding=json"

  class Bot
    Log = ::Log.for("bot")

    @client : Client

    @heartbeat_interval = 1000_u32
    @send_heartbeats = false
    @sequence : Int64? = nil 

    getter messages_history = [] of Event

    def initialize
      @client = Client.new(URI.parse(WS_BASE_URL))
      @client.on_message(&->on_message(Event))

      self.setup_heartbeats
    end

    def start
      @client.run
    end

    def close
      Log.info { "Stoping" }
      @client.close
      exit(0)
    end

    private def on_message(event : Event)
      Log.info { "Handling new event: #{event}" }

      case event.opcode
      when OP_HELLO
        payload = HelloPayload.from_json(event.data)
        self.handle_hello(payload.heartbeat_interval)
      when OP_HEARTBEAT_ACK
        # TODO: 
      when OP_INVALID_SESSION
        # TODO: 
      when OP_DISPATCH
        self.handle_dispatch(event.event_type.not_nil!, event.data)
      else
      end

      seq = event.sequence
      @sequence = seq if seq
      
      @messages_history << event
    end

    private def handle_hello(heartbeat_interval : Float32)
      @heartbeat_interval = heartbeat_interval
      @send_heartbeats = true

      self.identify
    end

    private def identify
      intents = DISCORD_INTENTS.map { |key, value| value }.sum
      Log.info { "identifying with intents=#{intents}" }

      payload = IdentifyPayload.new(
        token: ENV["BOT_TOKEN"],
        properties: {os: "macos", browser: "Musiquita", device: "Musiquita"},
        presence: {status: "online", afk: false},
        intents: intents
      )

      @client.send({op: OP_IDENTIFY, d: payload}.to_json)
    end

    private def handle_dispatch(event_type : String, data : IO::Memory)
      call_event dispatch, {event_type, data}

      # TODO: 
    end

    private def setup_heartbeats
      spawn do
        loop do
          if @send_heartbeats
            Log.info { "Sending heartbeat" }
            seq = @sequence || 0
            @client.send({op: OP_HEARTBEAT, d: seq}.to_json)          
          end

          sleep @heartbeat_interval.milliseconds
        end
      end
    end

    # :nodoc:
    macro call_event(name, payload)
      @on_{{name}}_handlers.try &.each do |handler|
        begin
          handler.call({{payload}})
        rescue ex
          Log.error(exception: ex) { "An exception occurred in a user-defined event handler!" }
          Log.error { ex.inspect_with_backtrace }
        end
      end
    end

    # :nodoc:
    macro event(name, payload_type)
      def on_{{name}}(&handler : {{payload_type}} ->)
        (@on_{{name}}_handlers ||= [] of {{payload_type}} ->) << handler
      end
    end

    event dispatch, {String, IO::Memory}
  end
end

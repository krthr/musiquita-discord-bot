require "./client.cr"
require "./constants.cr"
require "./mapping/*"
require "./cache.cr"

module DiscordMusic
  WS_BASE_URL = "wss://gateway.discord.gg/?v=10&encoding=json"

  class Bot
    Log = ::Log.for("bot")

    getter cache = Cache.new
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

      @client.send IdentifyEvent.new(payload).to_json
    end

    private def handle_dispatch(event_type : String, data : IO::Memory)
      case event_type
      when "READY"
        payload = ReadyPayload.from_json(data)
      when "GUILD_CREATE"
        payload = GuildCreatePayload.from_json(data)
        guild = Guild.new(payload)

        @cache.cache guild

        payload.channels.each do |channel|
          @cache.cache channel
        end
      when "MESSAGE_CREATE"
        # TODO:
      when "PRESENCE_UPDATE"
        # TODO:
      when "VOICE_STATE_UPDATE"
        # TODO
      when "VOICE_SERVER_UPDATE"
        # TODO
      else
      end
    end

    private def setup_heartbeats
      spawn do
        loop do
          if @send_heartbeats
            Log.info { "Sending heartbeat" }
            @client.send HelloEvent.new(@sequence || 0).to_json
          end

          sleep @heartbeat_interval.milliseconds
        end
      end
    end
  end
end

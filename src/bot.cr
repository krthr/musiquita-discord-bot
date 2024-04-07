require "./client.cr"
require "./constants.cr"

module DiscordMusic
  WS_BASE_URL = "wss://gateway.discord.gg/?v=10&encoding=json"

  class Bot
    Log = ::Log.for("bot")

    @client : Client
    @already_identified = false

    def initialize
      @client = Client.new(URI.parse(WS_BASE_URL))

      @client.on opcode: 10 do |event|
        self.start_heartbeat(event.data.not_nil!["heartbeat_interval"].not_nil!.as_i)
      end

      @client.on opcode: 11 do |event|
        self.identify
      end

      @client.on opcode: 9 do |event|
        Log.info { "Invalid session" }
        self.stop
      end

      @client.on opcode: 0 do |event|
        self.process_event(event)
      end
    end

    private def start_heartbeat(heartbeat_interval : Int32)
      Log.info { "starting heartbeat" }

      spawn do
        loop do
          Log.info { "Hearbeating" }

          payload = {op: 1, d: nil}
          @client.send(payload.to_json)

          sleep(heartbeat_interval / 1000)
        end
      end
    end

    private def identify
      return if @already_identified

      intents = DISCORD_INTENTS.map { |key, value| value }.sum
      Log.info { "identifying with intents=#{intents}" }

      payload = {
        op: 2,
        d:  {
          token:      ENV["BOT_TOKEN"],
          properties: {os: "macos", browser: "Musiquita", device: "Musiquita"},
          presence:   {status: "online", afk: false},
          intents:    intents,
        },
      }

      @client.send(payload.to_json)
      @already_identified = true
    end

    def stop
      Log.info { "stopping bot" }
      @client.close
      exit(1)
    end

    private def process_event(event : Event)
      # event_name = event.t
    end

    def start
      @client.run
    end
  end
end

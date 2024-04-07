require "./client.cr"
require "./constants.cr"
require "./events.cr"

module DiscordMusic
  WS_BASE_URL = "wss://gateway.discord.gg/?v=10&encoding=json"

  class Bot
    Log = ::Log.for("bot")

    @client : Client
    @already_identified = false

    getter discord_servers = Hash(String, Events::GuildCreate).new
    getter chat_messages_history = Array(Events::MessageCreate).new

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

    private def register_guild(data : Events::GuildCreate)
      Log.info { "Registering guild with id=#{data.id} name=\"#{data.name}\"" }
      @discord_servers[data.id] = data
    end

    private def process_message(data : Events::MessageCreate)
      Log.info { "Processing message=\"#{data.content}\" by=#{data.member}" }
      @chat_messages_history << data

      if data.content.includes?("reproduce")
        guild_id = data.guild_id
        author_id = data.author.not_nil!.id
        voice_channel_id = @discord_servers[guild_id]
          .not_nil!
          .voice_states
          .find! { |voice_state| voice_state.user_id == author_id }
          .channel_id

        # TODO: start audio connection
      end
    end

    private def process_event(event : Event)
      Log.info { "Processing event event_type=#{event.event_type}" }

      json_data = event.data.nil? ? nil : event.data.to_json

      case event.event_type
      when "GUILD_CREATE"
        self.register_guild(Events::GuildCreate.from_json(json_data.not_nil!))
      when "MESSAGE_CREATE"
        self.process_message(Events::MessageCreate.from_json(json_data.not_nil!))
      else
      end
    end

    def stop
      Log.info { "stopping bot" }
      @client.close
      exit(1)
    end

    def start
      @client.run
    end
  end
end

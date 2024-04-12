require "dotenv"
Dotenv.load?

require "kemal"
require "log"

require "discordcr"
require "opus"

require "./audio"
require "./version"

intents = (
  Discord::Gateway::Intents::Guilds |
  Discord::Gateway::Intents::GuildMembers |
  Discord::Gateway::Intents::GuildVoiceStates |
  Discord::Gateway::Intents::GuildPresences |
  Discord::Gateway::Intents::GuildMessages |
  Discord::Gateway::Intents::GuildMessageTyping |
  Discord::Gateway::Intents::DirectMessages |
  Discord::Gateway::Intents::DirectMessageTyping
)

puts intents

client = Discord::Client.new(
  token: "Bot #{ENV["BOT_TOKEN"]}",
  client_id: 1224082962648141884_u64,
  intents: intents
)
cache = Discord::Cache.new(client)
client.cache = cache

current_user_id = nil

# The ID of the (text) channel in which the connect command was run, so the
# "Voice connected." message is sent to the correct channel
connect_channel_id = nil

# Where the created voice client will eventually be stored
voice_client = nil

client.on_ready do |payload|
  current_user_id = payload.user.id
end

client.on_message_create do |payload|
  puts payload.content

  if payload.content.starts_with? "!connect "
    # Used as:
    # !connect <guild ID> <channel ID>

    # Parse the command arguments
    ids = payload.content[9..-1].split(' ').map(&.to_u64)

    client.create_message(payload.channel_id, "Connecting...")
    connect_channel_id = payload.channel_id
    client.voice_state_update(ids[0].to_u64, ids[1].to_u64, false, false)
  elsif payload.content.starts_with? "!vs"
    # Used as:
    # !vs

    reply = begin
      vs = cache.resolve_voice_state(payload.guild_id.not_nil!, payload.author.id)
      vc = cache.resolve_channel(vs.channel_id.not_nil!)

      # The voice region will be nil if the channel is set to automatically determine it.
      rtc_region = vc.rtc_region || "Automatic"

      "You are connected to channel #{vs.channel_id} (region: #{rtc_region}) at guild #{vs.guild_id}"
    rescue
      "No voice state"
    end

    client.create_message(payload.channel_id, reply)
  elsif payload.content.starts_with? "!play"
    unless voice_client
      client.create_message(payload.channel_id, "Voice client is nil!")
      next
    end

    _, video_id = payload.content.split(" ")

    # Set the bot as speaking (green circle). This is important and has to be
    # done at least once in every voice connection, otherwise the Discord client
    # will not know who the packets we're sending belongs to.
    voice_client.not_nil!.send_speaking(true)

    client.create_message(payload.channel_id, "Playing file ...")

    sample_rate = 48_000
    channels = 2
    encoder = Opus::Encoder.new(sample_rate, 960, channels)

    client.create_message(payload.channel_id, "Getting audio from video id=#{video_id}...")

    Audio.download_video(video_id)
    input_file = File.open("#{video_id}.mp3", "r")

    client.create_message(payload.channel_id, "Generating raw file ...")

    audio_data = IO::Memory.new
    Audio.audio_to_raw(input_file, audio_data, sample_rate, channels)

    client.create_message(payload.channel_id, "Playing opus encoded file ...")

    buffer = Bytes.new(encoder.input_length, 0)
    Discord.every(20.milliseconds) do
      real_length = audio_data.read(buffer)

      if real_length.zero?
        Log.info { "No more data to send... Closing" }
        break
      end

      opus_encoded_data = encoder.encode(buffer)
      voice_client.not_nil!.play_opus(opus_encoded_data)
    end

    input_file.close
    input_file.delete

    GC.collect
  end
end

client.on_voice_server_update do |payload|
  puts "on_voice_server_update"

  begin
    vc = voice_client = Discord::VoiceClient.new(payload, client.session.not_nil!, current_user_id.not_nil!)
    vc.on_ready do
      client.create_message(connect_channel_id.not_nil!, "Voice connected.")
    end
    vc.run
  rescue e
    e.inspect_with_backtrace(STDOUT)
  end
end

get "/" do
  {
    channels:     cache.channels,
    members:      cache.members,
    voice_states: cache.voice_states,
  }.to_json
end

spawn do
  client.run
end

PORT = ENV.fetch("PORT", "3333").to_i
Kemal.run(PORT)

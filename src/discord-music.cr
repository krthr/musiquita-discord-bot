require "dotenv"
Dotenv.load?

require "kemal"
require "log"

require "discordcr"

require "./youtube"
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

    file = File.open("music.data")

    # The DCAParser class handles parsing of the DCA file. It doesn't do any
    # sending of audio data to Discord itself – that has to be done by
    # VoiceClient.
    parser = Discord::DCAParser.new(file)

    # A proper DCA(1) file contains metadata, which is exposed by DCAParser.
    # This metadata may be of interest, so here is some example code that uses
    # it.
    if metadata = parser.metadata
      tool = metadata.dca.tool
      client.create_message(payload.channel_id, "DCA file was created by #{tool.name}, version #{tool.version}.")

      if info = metadata.info
        client.create_message(payload.channel_id, "Song info: #{info.title} by #{info.artist}.") if info.title && info.artist
      end
    else
      client.create_message(payload.channel_id, "DCA file metadata is invalid!")
    end

    # Set the bot as speaking (green circle). This is important and has to be
    # done at least once in every voice connection, otherwise the Discord client
    # will not know who the packets we're sending belongs to.
    voice_client.not_nil!.send_speaking(true)

    client.create_message(payload.channel_id, "Playing DCA file ...")

    # For smooth audio streams Discord requires one packet every
    # 20 milliseconds. The `every` method measures the time it takes to run the
    # block and then sleeps 20 milliseconds minus that time before moving on to
    # the next iteration, ensuring accurate timing.
    #
    # When simply reading from DCA, the time it takes to read, process and
    # send the frame is small enough that `every` doesn't make much of a
    # difference (in fact, some users report that it actually makes things
    # worse). If the processing time is not negligibly slow because you're
    # doing something else than DCA parsing, or because you're reading from a
    # slow source, or for any other reason, then it is recommended to use
    # `every`. Otherwise, simply using a loop and `sleep`ing `20.milliseconds`
    # each time may suffice.
    Discord.every(20.milliseconds) do
      frame = parser.next_frame(reuse_buffer: true)
      break unless frame

      # Perform the actual sending of the frame to Discord.
      voice_client.not_nil!.play_opus(frame)
    end

    file.close
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

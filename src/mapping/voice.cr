module DiscordMusic
  struct VoiceState
    include JSON::Serializable

    getter guild_id : String?
    getter channel_id : String?
    getter user_id : String?
    getter member : GuildMember?
    getter session_id : String
  end
end

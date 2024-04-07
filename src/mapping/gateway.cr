module DiscordMusic
  struct ReadyPayload
    include JSON::Serializable

    getter v : Int32
    getter user : User
    getter guilds : Array(NamedTuple(id: String, unavailable: Bool))
    getter session_id : String
    getter resume_gateway_url : String
    getter shard : Tuple(Int32)?
    getter application : NamedTuple(id: String, flags: Int32)
  end

  struct GuildCreatePayload
    include JSON::Serializable

    getter id : String
    getter name : String
    getter icon : String?
    getter icon_hash : String?
    getter owner_id : String
    getter member_count : Int32
    getter voice_states : Array(VoiceState)
    getter members : Array(GuildMember)
    getter channels : Array(Channel)
  end
end

module DiscordMusic
  struct GuildMember
    include JSON::Serializable

    getter user : User?
    getter nick : String?
    getter avatar : String?
    getter roles : Array(String)
    getter deaf : Bool
    getter mute : Bool
  end

  struct Guild
    include JSON::Serializable

    getter id : String
    getter name : String
    getter owner_id : String
    getter icon : String?
    getter icon_hash : String?

    def initialize(payload : GuildCreatePayload)
      @id = payload.id
      @name = payload.name
      @icon = payload.icon
      @icon_hash = payload.icon_hash
      @owner_id = payload.owner_id
    end
  end
end

require "./client.cr"

module DiscordMusic
  module Events
    struct User
      include JSON::Serializable

      getter id : String
      getter username : String
    end

    struct Member
      include JSON::Serializable

      getter user : User?
      getter nick : String?
      getter avatar : String?
      getter mute : Bool?
    end

    struct VoiceState
      include JSON::Serializable

      getter guild_id : String?
      getter channel_id : String?
      getter user_id : String?
      getter member : Member?
      getter session_id : String
    end

    struct Channel
      include JSON::Serializable

      enum Type
        GUILD_TEXT        =  0
        DM                =  1
        GUILD_VOICE       =  2
        GROUP_DM          =  3
        PUBLIC_THREAD     = 11
        PRIVATE_THREAD    = 12
        GUILD_STAGE_VOICE = 13
        GUILD_MEDIA       = 16
      end

      getter id : String
      getter type : Int32
      getter guild_id : String?
      getter position : Int32?
      getter topic : String?
      getter name : String?
      getter bitrate : Int32?
      getter rtc_region : String?
      getter permissions : String?
      getter total_message_sent : String?
    end

    module Guild
      getter id : String
      getter name : String
    end

    struct GuildCreate
      include JSON::Serializable
      include Guild

      getter member_count : Int32
      getter voice_states : Array(VoiceState)
      getter members : Array(Member)
      getter channels : Array(Channel)
    end

    struct MessageCreate
      include JSON::Serializable

      getter id : String
      getter channel_id : String
      getter author : User?
      getter content : String
      getter guild_id : String
      getter member : Member?
    end

    struct PresenceUpdate
      include JSON::Serializable

      getter guild_id : String
      getter status : String
      getter user : User
    end
  end
end

module DiscordMusic
  enum ChannelType
    GuildText     = 0
    DM            = 1
    GuildVoice    = 2
    GroupDM       = 3
    GuildCategory = 4
    GuildNews     = 5
    GuildStore    = 6

    def self.new(pull : JSON::PullParser)
      ChannelType.new(pull.read_int.to_u8)
    end
  end

  struct Channel
    include JSON::Serializable

    getter id : String
    getter type : ChannelType
    getter guild_id : String?
    getter position : Int32?
    getter topic : String?
    getter name : String?
    getter bitrate : Int32?
    getter rtc_region : String?
    getter permissions : String?
    getter total_message_sent : String?
    getter parent_id : String?
  end
end

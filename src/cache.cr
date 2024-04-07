module DiscordMusic
  class Cache
    include JSON::Serializable

    getter guilds : Hash(String, Guild)
    getter channels : Hash(String, Channel)

    def initialize
      @guilds = {} of String => Guild
      @channels = {} of String => Channel
    end

    def get_guild(id : String)
      @guilds[id]?
    end

    def get_channel(id : String)
      @channels[id]?
    end

    def cache(guild : Guild)
      @guilds[guild.id] = guild
    end

    def cache(channel : Channel)
      @channels[channel.id] = channel
    end
  end
end

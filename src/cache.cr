module DiscordMusic
  class Cache
    include JSON::Serializable

    getter guilds : Hash(String, Guild)
    getter channels : Hash(String, Channel)
    getter members : Hash(String, Hash(String, GuildMember))

    def initialize
      @guilds = {} of String => Guild
      @channels = {} of String => Channel
      @members = {} of String => Hash(String, GuildMember)
    end

    def get_guild(id : String)
      @guilds[id]?
    end

    def get_channel(id : String)
      @channels[id]?
    end

    def get_member(guild_id : String, user_id : String)
      local_members = @members[guild_id] ||= Hash(String, GuildMember).new
      local_members[user_id]?
    end

    def cache(guild : Guild)
      @guilds[guild.id] = guild
    end

    def cache(channel : Channel)
      @channels[channel.id] = channel
    end

    def cache(member : GuildMember, guild_id : String)
      local_members = @members[guild_id] ||= Hash(String, GuildMember).new

      user = member.user
      local_members[user.id] = member unless user.nil?
    end
  end
end

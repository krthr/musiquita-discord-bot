module DiscordMusic
  DISCORD_INTENTS = {
    GUILDS:             1 << 0,
    GUILD_MEMBERS:      1 << 1,
    GUILD_VOICE_STATES: 1 << 7,
    GUILD_PRESENCES:    1 << 8,
    GUILD_MESSAGES:     1 << 9,
    DIRECT_MESSAGES:    1 << 12,
    MESSAGE_CONTENT:    1 << 15,
  }
end

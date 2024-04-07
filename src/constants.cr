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

  OP_DISPATCH           =  0
  OP_HEARTBEAT          =  1
  OP_IDENTIFY           =  2
  OP_PRESENCE_UPDATE    =  3
  OP_VOICE_STATE_UPDATE =  4
  OP_INVALID_SESSION    =  9
  OP_HELLO              = 10
  OP_HEARTBEAT_ACK      = 11
end

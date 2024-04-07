require "json"

module DiscordMusic
  struct HelloPayload
    include JSON::Serializable

    getter heartbeat_interval : Float32
  end

  struct IdentifyPayload
    include JSON::Serializable

    getter token : String
    getter properties : NamedTuple(os: String, browser: String, device: String)
    getter presence : NamedTuple(status: String, afk: Bool)
    getter intents : Int64

    def initialize(@token, @properties, @presence, @intents)
    end
  end
end

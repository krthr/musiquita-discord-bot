module DiscordMusic
  struct HelloPayload
    include JSON::Serializable

    getter heartbeat_interval : Float32
  end

  struct HelloEvent
    include JSON::Serializable

    getter op : Int32 = OP_HEARTBEAT
    getter d : Int64 | Int32

    def initialize(@d)
    end
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

  struct IdentifyEvent
    include JSON::Serializable

    getter op = OP_IDENTIFY
    getter d : IdentifyPayload

    def initialize(@d)
    end
  end
end

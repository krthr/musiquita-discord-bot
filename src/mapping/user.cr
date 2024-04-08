module DiscordMusic
  struct User
    include JSON::Serializable

    getter id : String
    getter username : String
    getter discriminator : String
    getter global_name : String?
    getter display_name : String?
    getter avatar : String?
    getter? bot : Bool?
  end
end

module DiscordMusic
  struct User
    include JSON::Serializable

    getter id : String
    getter username : String
    getter discriminator : String
    getter global_name : String?
    getter avatar : String?
  end
end

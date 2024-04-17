require "crest"
require "json"

module Music::Audio::Youtube
  class Api
    Log = ::Log.for("YoutubeApi")

    API_BASE        = "https://www.googleapis.com/youtube/v3"
    YOUTUBE_API_KEY = ENV["YOUTUBE_API_KEY"]

    @client = Crest::Resource.new(
      API_BASE,
      headers: {"Accept" => "application/json"},
      params: {"key" => YOUTUBE_API_KEY}
    )

    struct Thumbnail
      include JSON::Serializable
      property url : String
      property width : Int32
      property height : Int32
    end

    struct Snippet
      include JSON::Serializable

      @[JSON::Field(key: "channelId")]
      property channel_id : String

      property title : String

      @[JSON::Field(key: "channelTitle")]
      property channel_title : String

      property thumbnails : NamedTuple(default: Thumbnail, medium: Thumbnail, high: Thumbnail)
    end

    struct Resource
      include JSON::Serializable
      property id : NamedTuple(kind: String, video_id: String?)
      property snippet : Snippet
    end

    struct SearchResponse
      include JSON::Serializable
      property kind : String
      property etag : String

      @[JSON::Field(key: "regionCode")]
      property region_code : String

      property items : Array(Resource)
    end

    def search(query : String, limit = 1) : SearchResponse?
      Log.info { "Searching video by query=#{query}" }

      begin
        response = @client["/search"].get(
          params: {
            :part       => "id,snippet",
            :maxResults => limit,
            :order      => "relevance",
            :q          => query,
            :safeSearch => "none",
            :type       => "video",
          }
        )

        SearchResponse.from_json(response.body)
      rescue ex
        Log.error { ex }
      end
    end
  end
end

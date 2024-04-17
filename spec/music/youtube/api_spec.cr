require "spec"
require "../../../src/music/youtube/api.cr"

describe Music::Audio::Youtube::Api do
  it "searches videos" do
    api = Music::Audio::Youtube::Api.new

    results = api.search("all the rage back home interpol")
    results.should be_a(Music::Audio::Youtube::Api::SearchResponse)
    results.not_nil!.items.size.should eq(1)
  end
end

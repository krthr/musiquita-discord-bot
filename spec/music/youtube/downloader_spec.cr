require "spec"
require "../../../src/music/youtube/downloader.cr"

describe Music::Audio::Youtube::Downloader do
  it "downloads a youtube video" do
    output_io = Music::Audio::Youtube::Downloader.download("uUWrcFpmI5U")
    output_io.size.should be > 0
  end

  it "fails to download a youtube video" do
    expect_raises(Music::Audio::Youtube::Downloader::DownloadError) do
      Music::Audio::Youtube::Downloader.download("aaa")
    end
  end
end

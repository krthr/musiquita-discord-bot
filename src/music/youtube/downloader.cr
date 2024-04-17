require "file_utils"
require "log"

module Music::Audio::Youtube
  module Downloader
    Log = ::Log.for("YoutubeDownloader")

    class DownloadError < Exception
    end

    def self.download(video_id : String) : IO
      error = IO::Memory.new
      output = IO::Memory.new

      Log.info { "Downloading video with id=#{video_id}" }

      Dir.mkdir("tmp") unless Dir.exists?("tmp")

      status = Process.run(
        "yt-dlp -f size,ba -x --audio-format mp3 -o - #{video_id}",
        shell: true,
        error: error,
        output: output,
      )

      raise DownloadError.new(error.to_s) unless status.success?

      output.rewind
      output
    end
  end
end

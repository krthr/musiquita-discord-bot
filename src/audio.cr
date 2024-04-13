module Audio
  class YouTubeDownloader
    def self.download(video_id : String)
      error = IO::Memory.new
      output = IO::Memory.new

      Process.run(
        "yt-dlp -f ba -x --audio-format mp3 -o - #{video_id}",
        shell: true,
        output: output,
        error: error,
      )

      output.rewind
      output
    end
  end

  class FfmpegEncoder
    def self.encode(input : IO) : IO
      error = IO::Memory.new
      output = IO::Memory.new

      Process.run(
        "ffmpeg -i pipe:0 -loglevel verbose -f s16le -ar 48000 -ac 2 pipe:1",
        shell: true,
        input: input,
        output: output,
        error: error
      )

      output.rewind
      output
    end
  end
end

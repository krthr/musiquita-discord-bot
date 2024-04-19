require "file_utils"
require "log"

module Music::Audio::Youtube
  Log = ::Log.for("Youtube")

  DOWNLOAD_AUDIO_FOLDER = "./tmp/audio"
  Dir.mkdir_p(DOWNLOAD_AUDIO_FOLDER) unless Dir.exists?(DOWNLOAD_AUDIO_FOLDER)

  class DownloadError < Exception
  end

  def self.download(video_id : String)
    Log.info { "Downloading video with id=#{video_id}" }

    file_path = File.join(DOWNLOAD_AUDIO_FOLDER, "#{video_id}.mp3")

    if File.exists?(file_path)
      Log.info { "File already exists ;) Returning it" }
      return File.open(file_path)
    end

    file = self.download_to_io(video_id)
    File.write(file_path, file)

    file.rewind
    file
  end

  private def self.download_to_io(video_id : String) : IO
    Log.info { "Running yt-dlp..." }

    error = IO::Memory.new
    output = IO::Memory.new

    command = "yt-dlp -f size,ba -x --audio-format mp3 -o - #{video_id}"
    status = Process.run(command, shell: true, error: error, output: output)

    raise DownloadError.new(error.to_s) unless status.success?

    output.rewind
    output
  end
end

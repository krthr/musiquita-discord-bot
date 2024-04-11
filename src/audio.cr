module Audio
  def self.download_video(video_id : String)
    Log.info { "Downloading video with id=#{video_id} to file" }

    Process.run(
      "yt-dlp -f ba -x --audio-format mp3 --no-progress -o #{video_id}.mp3 #{video_id}",
      shell: true,
      output: STDOUT,
      error: STDOUT
    )
  end

  def self.audio_to_raw(input : IO, output : IO, sample_rate : Int32, channels : Int32)
    Log.info { "Converting audio to raw..." }

    Process.run("ffmpeg",
      ["-i", "pipe:0",
       "-loglevel", "0",
       "-f", "s16le",
       "-ar", sample_rate.to_s,
       "-ac", channels.to_s,
       "pipe:1",
      ],
      shell: true,
      input: input,
      output: output,
      error: STDOUT
    )

    output.rewind
  end
end

COMMAND = "yt-dlp -o - -f ba -x --audio-format mp3 --no-progress %s"

def stream_video(id : String, output : IO)
  Process.run(COMMAND % id, shell: true) do |process|
    Log.info { "Sending audio content..." }

    if process.output?
      IO.copy(process.output?, output)
    else
      Log.error { "Process output is nil." }
    end

    Log.info { "Done." }
  end
end

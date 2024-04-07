require "log"

COMMAND = "yt-dlp -o - -f ba -x --audio-format mp3 --no-progress %s"

def stream_video(id : String, output : IO)
  Process.run(COMMAND % id, shell: true) do |process|
    Log.info { "Sending audio content..." }
    IO.copy(process.output?.not_nil!, output)
    Log.info { "Done." }
  end
end
# TODO:

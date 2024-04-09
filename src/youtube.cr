COMMAND = "yt-dlp -f ba -x --audio-format opus --audio-quality 48K --no-progress -o file.opus %s"

def stream_video(id : String)
  Process.run(COMMAND % id, shell: true, error: STDOUT)
end

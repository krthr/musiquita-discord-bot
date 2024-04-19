require "log"

module Audio
  module Ffmpeg
    Log = ::Log.for("Ffmpeg")

    COMMAND = "ffmpeg -i pipe:0 -loglevel verbose -f s16le -ar 48000 -ac 2 pipe:1"

    class FfmpegError < Exception
    end

    def self.encode(input : IO) : IO
      output = IO::Memory.new

      self.encode(input) do |chunk|
        output << chunk
      end

      output.rewind
      output
    end

    def self.encode(input : IO, &handler : Bytes ->)
      Log.info { "Encoding to raw..." }

      error = IO::Memory.new
      chunk = Bytes.new(5_000)

      Process.run(COMMAND, shell: true, input: input, error: error) do |process|
        output = process.output?
        while output && output.read(chunk) > 0
          yield chunk
        end
      end

      raise FfmpegError.new(error.to_s) unless $?.success?
    end
  end
end

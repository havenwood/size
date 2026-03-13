# frozen_string_literal: true

Size = Data.define(:width, :height)

require_relative "size/version"
require_relative "size/gif"

class Size
  class FormatError < StandardError
    def initialize(message = "unrecognized image format") = super
  end

  class << self
    def of(input)
      case input
      when String, Pathname
        File.open(input, "rb") { |io| read(io) }
      else
        read(input)
      end
    end

    private

    def read(io)
      header = io.read(12)
      raise FormatError, "could not read image header" unless header&.bytesize == 12

      if header.start_with?("\x89PNG".b)
        PNG.read(io, header)
      elsif header.start_with?("\xFF\xD8".b)
        JPEG.read(io, header)
      elsif header.start_with?("GIF".b)
        GIF.read(io, header)
      elsif header[0, 4] == "RIFF" && header[8, 4] == "WEBP"
        WebP.read(io, header)
      elsif header[4, 4] == "ftyp"
        AVIF.read(io, header)
      else
        raise FormatError
      end
    end
  end
end

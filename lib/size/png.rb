# frozen_string_literal: true

class Size::PNG < Size
  SIGNATURE = "\x89PNG\r\n\x1A\n".b

  def self.read(io, header)
    data = header
    rest = io.read(12)
    data += rest if rest
    raise Size::FormatError, "truncated PNG" unless data.bytesize == 24
    raise Size::FormatError, "invalid PNG signature" unless data.start_with?(SIGNATURE)

    width, height = data.unpack("x16N2")
    new(width:, height:)
  end
end

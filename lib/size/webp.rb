# frozen_string_literal: true

class Size::WebP < Size
  class << self
    def read(io, header)
      data = header
      rest = io.read(18)
      data += rest if rest
      fourcc = data.byteslice(12, 4)

      case fourcc
      when "VP8 "
        read_vp8(data)
      when "VP8L"
        read_vp8l(data)
      when "VP8X"
        read_vp8x(data)
      else
        raise Size::FormatError, "unrecognized WebP variant: #{fourcc.inspect}"
      end
    end

    private

    def read_vp8(data)
      raise Size::FormatError, "truncated WebP VP8" unless data.bytesize >= 30
      raise Size::FormatError, "invalid VP8 keyframe" unless data.byteslice(23, 3) == "\x9D\x01\x2A".b

      width, height = data.unpack("x26v2")
      new(width: width & 0x3FFF, height: height & 0x3FFF)
    end

    def read_vp8l(data)
      raise Size::FormatError, "truncated WebP VP8L" unless data.bytesize >= 25
      raise Size::FormatError, "invalid VP8L signature" unless data.getbyte(20) == 0x2F

      bits = data.unpack1("V", offset: 21)
      new(width: (bits & 0x3FFF) + 1, height: ((bits >> 14) & 0x3FFF) + 1)
    end

    def read_vp8x(data)
      raise Size::FormatError, "truncated WebP VP8X" unless data.bytesize >= 30

      w = data.getbyte(24) | (data.getbyte(25) << 8) | (data.getbyte(26) << 16)
      h = data.getbyte(27) | (data.getbyte(28) << 8) | (data.getbyte(29) << 16)
      new(width: w + 1, height: h + 1)
    end
  end
end

# frozen_string_literal: true

class Size::JPEG < Size
  SOF_MARKERS = ((0xC0..0xCF).to_a - [0xC4, 0xC8, 0xCC]).freeze
  STANDALONE = [0x00, 0x01, *0xD0..0xD9].freeze

  class << self
    def read(io, header)
      io = Size::PrefixedIO.new(header, io)
      raise Size::FormatError, "invalid JPEG" unless io.read(2) == "\xFF\xD8".b

      loop do
        marker = read_marker(io)
        raise Size::FormatError, "no SOF marker before end of image" if marker == 0xD9

        if SOF_MARKERS.include?(marker)
          seg = io.read(7)
          raise Size::FormatError, "truncated JPEG SOF" unless seg&.bytesize == 7

          height, width = seg.unpack("x3n2")
          return new(width:, height:)
        end

        skip_segment(io)
      end
    end

    private

    def read_marker(io)
      loop do
        byte = io.read(1)&.ord
        raise Size::FormatError, "truncated JPEG" unless byte
        next unless byte == 0xFF

        loop do
          marker = io.read(1)&.ord
          raise Size::FormatError, "truncated JPEG" unless marker
          next if marker == 0xFF
          next if STANDALONE.include?(marker)

          return marker
        end
      end
    end

    def skip_segment(io)
      len_bytes = io.read(2)
      raise Size::FormatError, "truncated JPEG" unless len_bytes&.bytesize == 2

      len = len_bytes.unpack1("n")
      skipped = io.read(len - 2)
      raise Size::FormatError, "truncated JPEG" unless skipped&.bytesize == len - 2
    end
  end
end

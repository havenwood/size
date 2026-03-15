# frozen_string_literal: true

class Size::JPEG < Size
  SOF_MARKERS = Set[*0xC0..0xCF] - [0xC4, 0xC8, 0xCC]
  STANDALONE = Set[0x00, 0x01, *0xD0..0xD8]

  class << self
    def read(io, _header)
      io.seek(-10, IO::SEEK_CUR)

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
      raise Size::FormatError, "invalid JPEG segment length" if len < 2

      io.seek(len - 2, IO::SEEK_CUR)
    end
  end
end

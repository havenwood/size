# frozen_string_literal: true

class Size::JXL < Size
  LENGTHS = [9, 13, 18, 30].freeze
  RATIOS = [[1, 1], [12, 10], [4, 3], [3, 2], [16, 9], [5, 4], [2, 1]].freeze

  class << self
    def read(io, header)
      return parse_size_header(header.byteslice(2, 9)) if header.start_with?("\xFF\x0A".b)

      read_container(io)
    end

    private

    def read_container(io)
      loop do
        box_header = io.read(8)
        raise Size::FormatError, "no codestream in JXL container" unless box_header&.bytesize == 8

        size = box_header.unpack1("N")
        type = box_header.byteslice(4, 4)

        case size
        when 1
          ext = io.read(8)
          raise Size::FormatError, "truncated JXL" unless ext&.bytesize == 8
          size = ext.unpack1("Q>")
          header_size = 16
        when (8..)
          header_size = 8
        else
          raise Size::FormatError, "invalid JXL box size: #{size}"
        end

        case type
        when "jxlc"
          return read_codestream(io)
        when "jxlp"
          io.seek(4, IO::SEEK_CUR)
          return read_codestream(io)
        else
          io.seek(size - header_size, IO::SEEK_CUR)
        end
      end
    end

    def read_codestream(io)
      data = io.read(11)
      raise Size::FormatError, "truncated JXL codestream" unless data&.bytesize == 11
      raise Size::FormatError, "invalid JXL codestream" unless data.start_with?("\xFF\x0A".b)

      parse_size_header(data.byteslice(2, 9))
    end

    def parse_size_header(data)
      bytes = data.unpack("C*")
      pos = 0

      read = ->(bits) do
        val = 0
        bits.times { val |= ((bytes[(pos + it) / 8] >> ((pos + it) % 8)) & 1) << it }
        pos += bits
        val
      end

      if read[1] == 1
        height = read[5].succ * 8
        ratio = read[3]
        width = ratio.zero? ? read[5].succ * 8 : apply_ratio(ratio, height)
      else
        height = read[LENGTHS[read[2]]].succ
        ratio = read[3]
        width = ratio.zero? ? read[LENGTHS[read[2]]].succ : apply_ratio(ratio, height)
      end

      new(width:, height:)
    end

    def apply_ratio(ratio, height)
      num, den = RATIOS[ratio - 1]
      height * num / den
    end
  end
end

# frozen_string_literal: true

class Size::AVIF < Size
  BRANDS = %w[avif avis].freeze

  class << self
    def read(io, header)
      data = header
      rest = io.read(500)
      data += rest if rest
      ftyp_size = data.unpack1("N")
      raise Size::FormatError, "not AVIF" unless avif_brand?(data, ftyp_size)

      find_ispe(data, ftyp_size)
    end

    private

    def avif_brand?(data, ftyp_size)
      return true if BRANDS.include?(data.byteslice(8, 4))

      offset = 16
      while offset + 4 <= ftyp_size
        return true if BRANDS.include?(data.byteslice(offset, 4))
        offset += 4
      end

      false
    end

    def find_ispe(data, pos)
      while pos + 8 <= data.bytesize
        size = data.unpack1("N", offset: pos)
        type = data.byteslice(pos + 4, 4)
        raise Size::FormatError, "invalid AVIF box" if size < 8

        case type
        when "ispe"
          raise Size::FormatError, "truncated AVIF" unless pos + 20 <= data.bytesize
          width, height = data.unpack("N2", offset: pos + 12)
          return new(width:, height:)
        when "meta"
          pos += 12 # FullBox header
        when "iprp", "ipco"
          pos += 8
        else
          pos += size
        end
      end

      raise Size::FormatError, "no dimensions found in AVIF"
    end
  end
end

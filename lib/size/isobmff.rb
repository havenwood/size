# frozen_string_literal: true

module Size::ISOBMFF
  def read_isobmff(data) = find_ispe(data, data.unpack1("N"))

  def brand?(data, ftyp_size)
    return true if self::BRANDS.include?(data.byteslice(8, 4))

    offset = 16
    while offset + 4 <= ftyp_size
      return true if self::BRANDS.include?(data.byteslice(offset, 4))

      offset += 4
    end

    false
  end

  private

  def find_ispe(data, pos)
    format_name = name.split("::").last

    while pos + 8 <= data.bytesize
      size = data.unpack1("N", offset: pos)
      type = data.byteslice(pos + 4, 4)
      raise Size::FormatError, "invalid #{format_name} box" if size < 8

      case type
      when "ispe"
        raise Size::FormatError, "truncated #{format_name}" unless pos + 20 <= data.bytesize
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

    raise Size::FormatError, "no dimensions found in #{format_name}"
  end
end

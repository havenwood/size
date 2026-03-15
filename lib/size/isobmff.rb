# frozen_string_literal: true

module Size::ISOBMFF
  def read_isobmff(io) = find_ispe(io)

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

  def find_ispe(io)
    format_name = name.split("::").last

    loop do
      box_header = io.read(8)
      raise Size::FormatError, "no dimensions found in #{format_name}" unless box_header&.bytesize == 8

      size = box_header.unpack1("N")
      type = box_header.byteslice(4, 4)

      if size == 1
        ext = io.read(8)
        raise Size::FormatError, "truncated #{format_name}" unless ext&.bytesize == 8
        size = ext.unpack1("Q>")
        header_size = 16
      else
        raise Size::FormatError, "invalid #{format_name} box" if size < 8
        header_size = 8
      end

      case type
      when "ispe"
        content = io.read(12)
        raise Size::FormatError, "truncated #{format_name}" unless content&.bytesize == 12

        width, height = content.unpack("x4N2")
        return new(width:, height:)
      when "meta"
        io.read(4)
      when "iprp", "ipco"
        nil
      else
        io.seek(size - header_size, IO::SEEK_CUR)
      end
    end
  end
end

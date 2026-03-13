# frozen_string_literal: true

class Size::GIF < Size
  def self.read(_io, header)
    unless header.start_with?("GIF87a", "GIF89a")
      raise Size::FormatError, "invalid GIF signature"
    end

    width, height = header.unpack("x6v2")
    new(width:, height:)
  end
end

# frozen_string_literal: true

class Size::PrefixedIO
  def initialize(prefix, io)
    @prefix = prefix
    @io = io
    @pos = 0
  end

  def read(n)
    return @io.read(n) if @pos >= @prefix.bytesize

    from_prefix = @prefix.byteslice(@pos, n)
    @pos += from_prefix.bytesize
    remaining = n - from_prefix.bytesize

    if remaining > 0
      from_io = @io.read(remaining)
      from_prefix += from_io if from_io
    end

    from_prefix unless from_prefix.empty?
  end
end

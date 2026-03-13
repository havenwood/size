# frozen_string_literal: true

require_relative "test_helper"

class PNGTest < Minitest::Test
  def test_dimensions
    header = [
      "\x89PNG\r\n\x1A\n",
      "\x00\x00\x00\x0D",
      "IHDR",
      "\x00\x00\x03\x20",  # width: 800
      "\x00\x00\x02\x58"   # height: 600
    ].join.b

    size = Size.of(StringIO.new(header))

    assert_instance_of Size::PNG, size
    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_large_dimensions
    header = [
      "\x89PNG\r\n\x1A\n",
      "\x00\x00\x00\x0D",
      "IHDR",
      "\x00\x00\xFF\xFF",  # width: 65535
      "\x00\x00\xFF\xFF"   # height: 65535
    ].join.b

    size = Size.of(StringIO.new(header))

    assert_equal 65_535, size.width
    assert_equal 65_535, size.height
  end

  def test_truncated_png
    # 12 bytes passes header detection but PNG.read needs 24
    data = "\x89PNG\r\n\x1A\n\x00\x00\x00\x0D".b

    assert_raises(Size::FormatError) { Size.of(StringIO.new(data)) }
  end

  def test_invalid_png_signature
    header = [
      "\x89XNG\r\n\x1A\n",
      "\x00\x00\x00\x0D",
      "IHDR",
      "\x00\x00\x03\x20",
      "\x00\x00\x02\x58"
    ].join.b

    assert_raises(Size::FormatError) { Size.of(StringIO.new(header)) }
  end
end

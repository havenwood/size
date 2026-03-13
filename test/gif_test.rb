# frozen_string_literal: true

require_relative "test_helper"

class GIFTest < Minitest::Test
  def test_gif89a
    size = Size.of(StringIO.new("GIF89a\x03\x00\x05\x00\x00\x00\x00".b))

    assert_instance_of Size::GIF, size
    assert_equal 3, size.width
    assert_equal 5, size.height
  end

  def test_gif87a
    size = Size.of(StringIO.new("GIF87a\x0A\x00\x14\x00\x00\x00\x00".b))

    assert_instance_of Size::GIF, size
    assert_equal 10, size.width
    assert_equal 20, size.height
  end

  def test_invalid_gif_signature
    assert_raises(Size::FormatError) { Size.of(StringIO.new("GIF00a\x03\x00\x05\x00\x00\x00\x00".b)) }
  end
end

# frozen_string_literal: true

require_relative "test_helper"

class JPEGTest < Minitest::Test
  def test_baseline_jpeg
    sof = [0x00, 0x0B, 0x08, 0x02, 0x58, 0x03, 0x20, 0x03, 0x00, 0x00, 0x00].pack("C*")
    size = Size.of(StringIO.new("\xFF\xD8\xFF\xC0".b + sof))

    assert_instance_of Size::JPEG, size
    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_progressive_jpeg
    sof = [0x00, 0x0B, 0x08, 0x01, 0xF4, 0x02, 0x80, 0x03, 0x00, 0x00, 0x00].pack("C*")
    size = Size.of(StringIO.new("\xFF\xD8\xFF\xC2".b + sof))

    assert_instance_of Size::JPEG, size
    assert_equal 640, size.width
    assert_equal 500, size.height
  end

  def test_skips_app0_marker
    app0_len = [0x00, 0x10].pack("C*")
    app0_data = "\x00".b * 14
    sof = [0x00, 0x0B, 0x08, 0x00, 0xC8, 0x01, 0x90, 0x03, 0x00, 0x00, 0x00].pack("C*")

    data = "\xFF\xD8\xFF\xE0".b + app0_len + app0_data + "\xFF\xC0".b + sof
    size = Size.of(StringIO.new(data))

    assert_equal 400, size.width
    assert_equal 200, size.height
  end

  def test_skips_multiple_markers
    app0 = "\xFF\xE0\x00\x04\x00\x00".b
    dqt = "\xFF\xDB\x00\x05\x00\x00\x00".b
    sof = [0x00, 0x0B, 0x08, 0x01, 0x00, 0x01, 0x00, 0x03, 0x00, 0x00, 0x00].pack("C*")

    data = "\xFF\xD8".b + app0 + dqt + "\xFF\xC0".b + sof
    size = Size.of(StringIO.new(data))

    assert_equal 256, size.width
    assert_equal 256, size.height
  end

  def test_handles_ff_padding
    sof = [0x00, 0x0B, 0x08, 0x00, 0x0A, 0x00, 0x14, 0x03, 0x00, 0x00, 0x00].pack("C*")
    size = Size.of(StringIO.new("\xFF\xD8\xFF\xFF\xC0".b + sof))

    assert_equal 20, size.width
    assert_equal 10, size.height
  end

  def test_truncated_jpeg
    data = "\xFF\xD8\xFF\xE0\x00\x10\x00\x00\x00\x00\x00\x00".b

    assert_raises(Size::FormatError) { Size.of(StringIO.new(data)) }
  end
end

# frozen_string_literal: true

require_relative "test_helper"

class WebPTest < Minitest::Test
  def test_vp8_lossy
    size = Size.of(StringIO.new(build_riff("VP8 ", vp8_chunk(800, 600))))

    assert_instance_of Size::WebP, size
    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_vp8_masks_scale_bits
    chunk_data = "\x00\x00\x00\x9D\x01\x2A\x20\xC3\x58\x82".b
    size = Size.of(StringIO.new(build_riff("VP8 ", [chunk_data.bytesize].pack("V") + chunk_data)))

    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_vp8l_lossless
    bits = (799 & 0x3FFF) | ((599 & 0x3FFF) << 14)
    chunk_data = "\x2F".b + [bits].pack("V")
    size = Size.of(StringIO.new(build_riff("VP8L", [chunk_data.bytesize].pack("V") + chunk_data)))

    assert_instance_of Size::WebP, size
    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_vp8x_extended
    flags = "\x00\x00\x00\x00".b
    chunk_data = flags + [799].pack("V")[0, 3] + [599].pack("V")[0, 3]
    size = Size.of(StringIO.new(build_riff("VP8X", [chunk_data.bytesize].pack("V") + chunk_data)))

    assert_instance_of Size::WebP, size
    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_vp8x_large_dimensions
    flags = "\x00\x00\x00\x00".b
    chunk_data = flags + [16_777_214].pack("V")[0, 3] + [16_777_214].pack("V")[0, 3]
    size = Size.of(StringIO.new(build_riff("VP8X", [chunk_data.bytesize].pack("V") + chunk_data)))

    assert_equal 16_777_215, size.width
    assert_equal 16_777_215, size.height
  end

  def test_vp8_invalid_sync_code
    chunk_data = "\x00\x00\x00\x00\x00\x00\x20\x03\x58\x02".b

    assert_raises(Size::FormatError) { Size.of(StringIO.new(build_riff("VP8 ", [chunk_data.bytesize].pack("V") + chunk_data))) }
  end

  def test_vp8l_invalid_signature
    chunk_data = "\x00".b + [0].pack("V")

    assert_raises(Size::FormatError) { Size.of(StringIO.new(build_riff("VP8L", [chunk_data.bytesize].pack("V") + chunk_data))) }
  end

  def test_unrecognized_variant
    assert_raises(Size::FormatError) { Size.of(StringIO.new(build_riff("VP8Z", [4].pack("V") + "\x00\x00\x00\x00".b))) }
  end

  def test_truncated_webp
    assert_raises(Size::FormatError) { Size.of(StringIO.new("RIFF\x00\x00\x00\x00WEBP".b)) }
  end

  private

  def build_riff(fourcc, payload)
    "RIFF".b + [4 + fourcc.bytesize + payload.bytesize].pack("V") + "WEBP" + fourcc + payload
  end

  def vp8_chunk(width, height)
    chunk_data = "\x00\x00\x00\x9D\x01\x2A".b + [width, height].pack("v2")
    [chunk_data.bytesize].pack("V") + chunk_data
  end
end

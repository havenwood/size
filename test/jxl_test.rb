# frozen_string_literal: true

require_relative "test_helper"

class JXLTest < Minitest::Test
  def test_small_mode
    data = "\xFF\x0A\x07\x0E".b + "\x00".b * 8
    size = Size.of(StringIO.new(data))

    assert_instance_of Size::JXL, size
    assert_equal 64, size.width
    assert_equal 32, size.height
  end

  def test_small_mode_with_ratio
    data = "\xFF\x0A\x7F\x00".b + "\x00".b * 8
    size = Size.of(StringIO.new(data))

    assert_equal 256, size.width
    assert_equal 256, size.height
  end

  def test_standard_mode
    data = "\xFF\x0A\x78\x07\x7E\x02".b + "\x00".b * 6
    size = Size.of(StringIO.new(data))

    assert_equal 320, size.width
    assert_equal 240, size.height
  end

  def test_standard_mode_with_ratio
    data = "\xFF\x0A\xBA\x21\x05".b + "\x00".b * 7
    size = Size.of(StringIO.new(data))

    assert_equal 1920, size.width
    assert_equal 1080, size.height
  end

  def test_container
    jxl_sig = "\x00\x00\x00\x0CJXL \x0D\x0A\x87\x0A".b
    ftyp = [20].pack("N") + "ftypjxl " + [0].pack("N") + "jxl "
    codestream = "\xFF\x0A\x07\x0E".b + "\x00".b * 7
    jxlc = [8 + codestream.bytesize].pack("N") + "jxlc" + codestream

    size = Size.of(StringIO.new(jxl_sig + ftyp + jxlc))

    assert_instance_of Size::JXL, size
    assert_equal 64, size.width
    assert_equal 32, size.height
  end

  def test_container_with_jxlp
    jxl_sig = "\x00\x00\x00\x0CJXL \x0D\x0A\x87\x0A".b
    ftyp = [20].pack("N") + "ftypjxl " + [0].pack("N") + "jxl "
    codestream = "\xFF\x0A\x78\x07\x7E\x02".b + "\x00".b * 5
    seq_num = [0].pack("N")
    jxlp = [8 + 4 + codestream.bytesize].pack("N") + "jxlp" + seq_num + codestream

    size = Size.of(StringIO.new(jxl_sig + ftyp + jxlp))

    assert_equal 320, size.width
    assert_equal 240, size.height
  end

  def test_container_with_extended_size_box
    jxl_sig = "\x00\x00\x00\x0CJXL \x0D\x0A\x87\x0A".b
    ftyp = [1].pack("N") + "ftyp" + [28].pack("Q>") + "jxl " + [0].pack("N") + "jxl "
    codestream = "\xFF\x0A\x07\x0E".b + "\x00".b * 7
    jxlc = [8 + codestream.bytesize].pack("N") + "jxlc" + codestream

    size = Size.of(StringIO.new(jxl_sig + ftyp + jxlc))

    assert_equal 64, size.width
    assert_equal 32, size.height
  end

  def test_truncated_codestream_in_container
    jxl_sig = "\x00\x00\x00\x0CJXL \x0D\x0A\x87\x0A".b
    ftyp = [20].pack("N") + "ftypjxl " + [0].pack("N") + "jxl "
    jxlc = [12].pack("N") + "jxlc" + "\xFF\x0A\x07\x0E".b

    assert_raises(Size::FormatError) { Size.of(StringIO.new(jxl_sig + ftyp + jxlc)) }
  end

  def test_truncated_container
    jxl_sig = "\x00\x00\x00\x0CJXL \x0D\x0A\x87\x0A".b

    assert_raises(Size::FormatError) { Size.of(StringIO.new(jxl_sig)) }
  end
end

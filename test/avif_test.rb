# frozen_string_literal: true

require_relative "test_helper"

class AVIFTest < Minitest::Test
  def test_avif_dimensions
    size = Size.of(StringIO.new(build_avif(800, 600)))

    assert_instance_of Size::AVIF, size
    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_avis_brand
    size = Size.of(StringIO.new(build_avif(320, 240, major_brand: "avis")))

    assert_instance_of Size::AVIF, size
    assert_equal 320, size.width
    assert_equal 240, size.height
  end

  def test_mif1_with_avif_compatible_brand
    ftyp = [20].pack("N") + "ftypmif1" + [0].pack("N") + "avif"
    size = Size.of(StringIO.new(ftyp + build_meta(1920, 1080)))

    assert_equal 1920, size.width
    assert_equal 1080, size.height
  end

  def test_skips_boxes_before_iprp
    ftyp = [16].pack("N") + "ftypavif" + [0].pack("N")
    hdlr = build_box("hdlr", "\x00" * 12)
    pitm = build_box("pitm", "\x00" * 6)
    iprp_content = build_iprp(640, 480)
    meta = [12 + hdlr.bytesize + pitm.bytesize + iprp_content.bytesize].pack("N") + "meta" + [0].pack("N") + hdlr + pitm + iprp_content

    size = Size.of(StringIO.new(ftyp + meta))

    assert_equal 640, size.width
    assert_equal 480, size.height
  end

  def test_non_avif_isobmff
    ftyp = [16].pack("N") + "ftypmp41" + [0].pack("N")

    assert_raises(Size::FormatError) { Size.of(StringIO.new(ftyp + ("\x00" * 50))) }
  end

  def test_invalid_box_size
    ftyp = [16].pack("N") + "ftypavif" + [0].pack("N")
    meta = [12].pack("N") + "meta" + [0].pack("N")
    bad_box = [0].pack("N") + "junk"

    assert_raises(Size::FormatError) { Size.of(StringIO.new(ftyp + meta + bad_box)) }
  end

  def test_truncated_avif
    ftyp = [16].pack("N") + "ftypavif" + [0].pack("N")

    assert_raises(Size::FormatError) { Size.of(StringIO.new(ftyp)) }
  end

  private

  def build_avif(width, height, major_brand: "avif")
    ftyp = [16].pack("N") + "ftyp" + major_brand + [0].pack("N")
    ftyp + build_meta(width, height)
  end

  def build_meta(width, height)
    iprp = build_iprp(width, height)
    [12 + iprp.bytesize].pack("N") + "meta" + [0].pack("N") + iprp
  end

  def build_box(type, content = "")
    [8 + content.bytesize].pack("N") + type + content
  end

  def build_iprp(width, height)
    ispe = [20].pack("N") + "ispe" + [0].pack("N") + [width, height].pack("N2")
    ipco = build_box("ipco", ispe)
    build_box("iprp", ipco)
  end
end

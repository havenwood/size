# frozen_string_literal: true

require_relative "test_helper"

class HEIFTest < Minitest::Test
  def test_heic_dimensions
    size = Size.of(StringIO.new(build_heif(800, 600)))

    assert_instance_of Size::HEIF, size
    assert_equal 800, size.width
    assert_equal 600, size.height
  end

  def test_heix_brand
    size = Size.of(StringIO.new(build_heif(320, 240, major_brand: "heix")))

    assert_instance_of Size::HEIF, size
    assert_equal 320, size.width
    assert_equal 240, size.height
  end

  def test_mif1_with_heic_compatible_brand
    ftyp = [20].pack("N") + "ftypmif1" + [0].pack("N") + "heic"
    size = Size.of(StringIO.new(ftyp + build_meta(1920, 1080)))

    assert_equal 1920, size.width
    assert_equal 1080, size.height
  end

  def test_truncated_heif
    ftyp = [16].pack("N") + "ftypheic" + [0].pack("N")

    assert_raises(Size::FormatError) { Size.of(StringIO.new(ftyp)) }
  end

  private

  def build_heif(width, height, major_brand: "heic")
    ftyp = [16].pack("N") + "ftyp" + major_brand + [0].pack("N")
    ftyp + build_meta(width, height)
  end

  def build_meta(width, height)
    iprp = build_iprp(width, height)
    [12 + iprp.bytesize].pack("N") + "meta" + [0].pack("N") + iprp
  end

  def build_iprp(width, height)
    ispe = [20].pack("N") + "ispe" + [0].pack("N") + [width, height].pack("N2")
    ipco = [8 + ispe.bytesize].pack("N") + "ipco" + ispe
    [8 + ipco.bytesize].pack("N") + "iprp" + ipco
  end
end

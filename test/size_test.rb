# frozen_string_literal: true

require_relative "test_helper"
require "tempfile"

class SizeTest < Minitest::Test
  def test_unrecognized_format
    assert_raises(Size::FormatError) { Size.of(StringIO.new("not an image!".b)) }
  end

  def test_empty_input
    assert_raises(Size::FormatError) { Size.of(StringIO.new("".b)) }
  end

  def test_too_short_input
    assert_raises(Size::FormatError) { Size.of(StringIO.new("\xFF\xD8".b)) }
  end

  def test_file_path_input
    with_tempfile do |path|
      size = Size.of(path)

      assert_equal 5, size.width
      assert_equal 10, size.height
    end
  end

  def test_pathname_input
    with_tempfile do |path|
      size = Size.of(Pathname(path))

      assert_equal 5, size.width
      assert_equal 10, size.height
    end
  end

  def test_pattern_matching
    header = "\x89PNG\r\n\x1A\n\x00\x00\x00\x0DIHDR\x00\x00\x00\x01\x00\x00\x00\x02".b
    size = Size.of(StringIO.new(header))

    assert_pattern { size => Size::PNG[width: 1, height: 2] }
    assert_pattern { size => {width: 1, height: 2} }
  end

  def test_pixels
    size = Size.of(StringIO.new("GIF89a\x03\x00\x05\x00\x00\x00\x00".b))

    assert_equal 15, size.pixels
  end

  def test_version_constant
    assert_match(/\A\d+\.\d+\.\d+\z/, Size::VERSION)
  end

  private

  def with_tempfile
    header = "\x89PNG\r\n\x1A\n\x00\x00\x00\x0DIHDR\x00\x00\x00\x05\x00\x00\x00\x0A".b
    Tempfile.create(["test", ".png"], binmode: true) do |f|
      f.write(header)
      f.rewind
      yield f.path
    end
  end
end

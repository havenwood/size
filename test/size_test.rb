# frozen_string_literal: true

require_relative "test_helper"

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

  def test_version_constant
    assert_match(/\A\d+\.\d+\.\d+\z/, Size::VERSION)
  end
end

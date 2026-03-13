# frozen_string_literal: true

require_relative "test_helper"

class PrefixedIOTest < Minitest::Test
  def test_reads_from_prefix_then_io
    prefix = "ABCD".b
    io = StringIO.new("EFGH".b)
    pio = Size::PrefixedIO.new(prefix, io)

    assert_equal "ABCDEFGH", pio.read(8)
  end

  def test_reads_entirely_from_prefix
    prefix = "ABCDEFGH".b
    io = StringIO.new("IJKL".b)
    pio = Size::PrefixedIO.new(prefix, io)

    assert_equal "ABCD", pio.read(4)
  end

  def test_reads_entirely_from_io_after_prefix_exhausted
    prefix = "AB".b
    io = StringIO.new("CDEF".b)
    pio = Size::PrefixedIO.new(prefix, io)

    pio.read(2) # exhaust prefix
    assert_equal "CD", pio.read(2)
  end

  def test_sequential_reads_across_boundary
    prefix = "ABC".b
    io = StringIO.new("DEF".b)
    pio = Size::PrefixedIO.new(prefix, io)

    assert_equal "AB", pio.read(2)
    assert_equal "CD", pio.read(2)
    assert_equal "EF", pio.read(2)
  end

  def test_returns_nil_at_eof
    prefix = "AB".b
    io = StringIO.new("".b)
    pio = Size::PrefixedIO.new(prefix, io)

    pio.read(2)
    assert_nil pio.read(1)
  end
end

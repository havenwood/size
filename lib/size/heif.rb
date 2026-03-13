# frozen_string_literal: true

class Size::HEIF < Size
  BRANDS = %w[heic heix hevc hevx heim heis hevm hevs].freeze

  extend Size::ISOBMFF
end

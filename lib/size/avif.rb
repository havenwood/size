# frozen_string_literal: true

class Size::AVIF < Size
  BRANDS = %w[avif avis].freeze

  extend Size::ISOBMFF
end

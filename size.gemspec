# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "size"
  spec.version = File.read(File.join(__dir__, "lib/size/version.rb"))[/VERSION = "(.+)"/, 1]
  spec.authors = ["Shannon Skipper"]
  spec.email = ["shannonskipper@gmail.com"]

  spec.summary = "Detect image dimensions with minimal reads"
  spec.description = "A pure Ruby library for detecting image dimensions by reading the minimum bytes from AVIF, GIF, HEIF, JPEG, JPEG XL, PNG and WebP files"
  spec.homepage = "https://github.com/havenwood/size"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0"

  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = %w[LICENSE.txt Rakefile README.md] + Dir["lib/**/*.rb"]
end

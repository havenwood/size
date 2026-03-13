# Size

Detect image dimensions with minimal reads. Pure Ruby, zero dependencies.

## Usage

```ruby
size = Size.of("photo.jpg")
size.width  #=> 1920
size.height #=> 1080
size.class  #=> Size::JPEG
```

Accepts a file path, `Pathname` or any readable IO:

```ruby
File.open("photo.png", "rb") { |io| Size.of(io) }
```

Pattern matching works since `Size` is a `Data` class:

```ruby
case Size.of(path)
in Size::PNG[width:, height:]
  "PNG: #{width}x#{height}"
in Size::JPEG[width:, height:]
  "JPEG: #{width}x#{height}"
end
```

Supports AVIF, GIF, JPEG, PNG and WebP. Raises `Size::FormatError` for unrecognized or truncated formats.

## Installation

```bash
gem install size
```

Or add to your Gemfile:

```ruby
gem "size"
```

## Alternatives

**[FastImage](https://github.com/sdsykes/fastimage)** is the most popular choice. It fetches dimensions from URLs, covers many more formats (BMP, TIFF, ICO, PSD, SVG and others) and has years of production use behind it. Locally it reads through a Fiber-based pipeline in 256-byte chunks.

**[ImageSize](https://github.com/toy/image_size)** has the broadest format coverage, with BMP, PSD, SWF, XPM and more. It reads in cached 4,096-byte chunks.

**Size** supports five image formats and works only with local files and IO objects. Size aims to be very memory efficient, reading only what each format requires: 24 bytes for a PNG, 10 for a GIF, 25–30 for WebP. All three gems walk JPEG marker segments, but FastImage has 256 bytes in memory before it begins, ImageSize has 4,096 and Size has 12.

For URL support or broad format coverage, use FastImage or ImageSize. For the smallest possible memory usage, use Size.

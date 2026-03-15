# Size

Detect AVIF, GIF, HEIF, JPEG, PNG and WebP image dimensions with minimal memory usage. Pure Ruby, no deps.

## Usage

```ruby
size = Size.of("photo.jpg")
size.width  #=> 1920
size.height #=> 1080
size.pixels #=> 2073600
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

Supports AVIF, GIF, HEIF, JPEG, PNG and WebP. Raises `Size::FormatError` for unrecognized or truncated formats.

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

**[Size](https://github.com/havenwood/size)** covers six formats and works only with local files and I/O objects. It reads the minimum each format requires: 10 bytes for a GIF, 24 for a PNG, 25–30 for WebP and a small number of box headers for AVIF and HEIF. All three gems stream through JPEG markers, but FastImage begins with 256 bytes in memory, ImageSize with 4,096 and Size with 12.

For URL support or broad format coverage, use FastImage or ImageSize. For the smallest possible memory usage, use Size.

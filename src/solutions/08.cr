class Aoc2019::Eight < Aoc2019::Solution

  def self.decode(image, width, height)
    layers = [] of Array(Array(Char))
    pixels = width * height
    chars = image.chars
    while chars.size >= pixels
      layer_pixels = chars.shift(pixels)
      layer = [] of Array(Char)
      while layer_pixels.size >= width
        layer << layer_pixels.shift(width) # shift a row off
      end
      layers << layer
    end
    layers
  end

  def self.part1_test
    image = "123456789012"
    decode image, 3, 2
  end

  def self.part1
    image = File.read("inputs/08")
    layers = decode image, 25, 6
    fewest_zeroes = 10000000000
    winner = nil
    layers.each do |layer|
      zeroes_count = layer.flatten.count{|p|p=='0'}
      if zeroes_count < fewest_zeroes
        fewest_zeroes = zeroes_count
        winner = layer
      end
    end
    return if winner.nil?
    winner.flatten.count{|p|p=='1'} * winner.flatten.count{|p|p=='2'}
  end

  def self.part2
    image = File.read("inputs/08")
    width, height = 25, 6
    layers = decode image, width, height 

    render = Array(Array(Char)).new(height) do
      Array(Char).new(width, '?')
    end

    layers.each do |layer|
      layer.each.with_index do |row, y|
        row.each.with_index do |pixel, x|
          next unless render[y][x] == '?'
          next unless pixel == '0' || pixel == '1'
          render[y][x] = pixel=='0' ? ' ' : '@'
        end
      end
    end

    render.each do |row|
      row.each do |pixel|
        print pixel
      end
      puts
    end

  end

end

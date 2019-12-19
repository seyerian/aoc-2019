class Aoc2019::Sixteen < Aoc2019::Solution
  def self.fft_pattern(index : Int32) # 1-based
    [0, 1, 0, -1].map{|x|[x]*index}.flatten.rotate
  end

  def self.fft_phase(input : Array(Int32))
    return unless input.is_a?(Array(Int32))
    output = Array(Int32).new
    input.size.times do |i|
      multiplications = Array(Int32).new
      fft_pattern(i+1).cycle.with_index do |p, j|
        break if j > input.size - 1
        multiplications << input[j] * p
      end
      output << multiplications.sum.to_s.chars.last.to_i32
    end
    output
  end

  def self.fft(input : Array(Int32), phases : Int32)
    phases.times do |i|
      input = fft_phase(input)
      exit if input.nil?
    end
    input.map(&.to_s).join
  end

  def self.str_to_fft_input(input : String)
    input.chars.map(&.to_i32)
  end

  def self.part1_test1
    fft str_to_fft_input("12345678"), 4
  end

  def self.part1_test2
    result = fft str_to_fft_input("80871224585914546619083218645595"), 100
    result.chars.first(8).join
  end

  def self.part1_test3
    result = fft str_to_fft_input("19617804207202209144916044189917"), 100
    result.chars.first(8).join
  end

  def self.part1_test4
    result = fft str_to_fft_input("69317163492948606335995924319873"), 100
    result.chars.first(8).join
  end

  def self.part1
    result = fft str_to_fft_input(File.read_lines("inputs/16").first), 100
    result.chars.first(8).join
  end
end

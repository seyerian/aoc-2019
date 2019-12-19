class Aoc2019::Sixteen < Aoc2019::Solution
  # args are 1-based
  def self.fft_pattern_value(scale : Int32, index : Int32)
    index += 1
    # 1 ABAC
    # 2 AABBAACC
    # 3 AAABBBAAACCC
    # 4 AAAABBBBAAAACCCC
    #     3 2 1 (i/s).ceil - 1
    # x +------
    # 1 | 0 0 0
    # 2 | 0 0 1
    # 3 | 0 1 2
    # 4 | 1 1 3
    # 5 | 1 2 4
    # 6 | 1 2 5
    # 7 | 2 3 6
    # 8 | 2 3 7
    # 9 | 2 4 8
    #10 | 3 4 9
    #11 | 3 5 10
    #key = ((index.to_f / scale).ceil - 1).to_i32
    key = (index - 1) // scale # // is floored division
    key = key % 4
    [0, 1, 0, -1][key]
  end

  def self.ones(n : Int32)
  end

  def self.fft_phase(input : Array(Int32))
    return unless input.is_a?(Array(Int32))
    output = Array(Int32).new
    input.size.times do |i|
      #puts "i@#{i+1}/#{input.size}"
      sum = 0
      input.size.times do |j|
        pv = fft_pattern_value(i+1, j+1)
        next if pv.zero?
        #puts "j@#{j+1}/#{input.size}"
        sum += input[j] * pv
      end
      no_ones = (sum.abs // 10 * 10)
      output << (no_ones.zero? ? sum.abs : sum.abs % no_ones)
      #sum.to_s.chars.last.to_i32
    end
    output
  end

  def self.fft(input : Array(Int32), phases : Int32)
    phases.times do |i|
      #puts "phase #{i+1}"
      input = fft_phase(input)
      exit if input.nil?
    end
    result = input.map(&.to_s).join
    result.chars.first(8).join
  end

  def self.str_to_fft_input(input : String)
    input.chars.map(&.to_i32)
  end

  def self.part1_test1
    fft str_to_fft_input("12345678"), 4
  end

  def self.part1_test2
    fft str_to_fft_input("80871224585914546619083218645595"), 100
  end

  def self.part1_test3
    fft str_to_fft_input("19617804207202209144916044189917"), 100
  end

  def self.part1_test4
    fft str_to_fft_input("69317163492948606335995924319873"), 100
  end

  def self.part1
    fft str_to_fft_input(File.read_lines("inputs/16").first), 100
  end

  def self.part2_test2
    fft str_to_fft_input("80871224585914546619083218645595" * 10_000), 100
  end
end

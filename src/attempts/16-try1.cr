class Aoc2019::Sixteen < Aoc2019::Solution
  def self.fft_pattern(index : Int32) # 1-based
    #puts "fft_pattern (#{4 * index})"
    [0, 1, 0, -1]#.map{|x|[x]*index}.flatten.rotate
  end

  def self.fft_phase(input : Array(Int32), input_repeat : Int32)
    puts "fft_phase #{input.map(&.to_s).join}"
    exit
    output = Array(Int32).new
    input_repeat.times do |r|
      #puts "repeat (#{r})"
      r = r+1 # make 1-based
      input.size.times do |i| # once for each input digit
        #puts "i (#{i})"
        multiplications = Array(Int32).new
        fft_pattern((r*i)+1).cycle.with_index do |p, j|
          break if j > input.size - 1
          multiplications << input[j] * p
        end
        output << (multiplications.sum * input_repeat).to_s.chars.last.to_i32
      end
    end
    output
  end

  def self.fft(input : Array(Int32), phases : Int32, input_repeat = 1)
    message_offset = 0
    if input_repeat > 1
      message_offset = input.first(7).map(&.to_s).join.to_i32
    end
    phases.times do |i|
      puts "phase #{i+1}"
      input = fft_phase(input, input_repeat)
      exit if input.nil?
    end
    result = 
      if input_repeat > 1
        message_offset.times do
          input.shift
        end
        input.first(8).map(&.to_s).join
      else
        input.map(&.to_s).join
      end
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
    fft str_to_fft_input("80871224585914546619083218645595"), 100, 10_000
  end
end

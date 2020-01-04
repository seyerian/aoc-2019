class Aoc2019::Nineteen < Aoc2019::Solution

  def self.part1
    computer = IntcodeComputer.new File.read("inputs/19")
    outputs = Array(Int64).new
    coords = (0..49).to_a.repeated_permutations 2
    current = [] of Int32
    computer.input = ->(ic : IntcodeComputer) {
      current = coords.shift if current.empty?
      current.shift.to_i64
    }
    computer.output = ->(ic : IntcodeComputer, o : Int64) {
      outputs << o
      true
    }
    until coords.empty? && current.empty?
      computer.reset
      computer.run
    end
    outputs.count{|n|n==1}
  end

  class TractorBeamChecker
    getter checks
    def initialize
      @checks = Hash(NamedTuple(x: Int32, y: Int32), Bool).new
      @computer = IntcodeComputer.new File.read("inputs/19")
    end
    
    def first_square(size : Int32)
      last_width size
    end

    def last_width(size : Int32)
      found_bound = false
      found = false
      y = 1
      until found_bound && found
        puts "y: #{y}"
        beam_length = 0
        1.to y do |x|
          if check x, y
            beam_length += 1
          else break if beam_length > 0
          end
        end
        puts "beam length: #{beam_length}"
        if found_bound
          if beam_length == size
            found = true
          else
            y -= 1
          end
        else
          if beam_length > size
            found_bound = true
          else
            y += 50
          end
        end
      end
      y
    end

    def check(x : Int32, y : Int32)
      digits = [x,y]
      @computer.input = ->(ic : IntcodeComputer) {
        digits.shift.to_i64
      }
      @computer.output = ->(ic : IntcodeComputer, o : Int64) {
        @checks[{x: x, y: y}] = (o==1)
      }
      @computer.reset
      @computer.run
      @checks[{x: x, y: y}]
    end
  end

  def self.part2
    checker = TractorBeamChecker.new
    checker.last_width 100
  end

end

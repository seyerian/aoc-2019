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
    getter map
    def initialize
      @map = Map.new(['.','#'])
      @computer = IntcodeComputer.new File.read("inputs/19")
      @squares = Array(NamedTuple(x: Int16, y: Int16)).new
    end

    def find_square(desired_size : Int32)
      y = 0
      size = 1
      last_x = 0
      loop do
        x = (last_x-5..y*3).find{|x| beam?(x,y)}
        unless x.nil?
          last_x = x
          until !square_fits?(x, y-size+1, size)
            return {x: x, y: y-size+1} if size == desired_size
            size += 1
          end
        end
        size -= 1 if size > 1
        y += 1
      end
    end

    def square_fits?(x : Int32, y : Int32, size : Int32)
      if beam?(x+size-1,y) && beam?(x, y+size-1)
        @squares << {x: x.to_i16, y: y.to_i16}
        true
      else
        false
      end
    end

    def beam?(x : Int32, y : Int32)
      get(x.to_i16,y.to_i16)=='#'
    end

    def get(x : Int16, y : Int16)
      if char = @map.get_char(x, y)
        return char if char != Map::UNKNOWN_CHAR
      end
      digits = [x,y]
      @computer.input = ->(ic : IntcodeComputer) {
        digits.shift.to_i64
      }
      @computer.output = ->(ic : IntcodeComputer, o : Int64) {
        @map.set x, y, (o==1 ? '#' : '.')
      }
      @computer.reset
      @computer.run
      @map.get_char(x, y)
    end
  end

  def self.part2
    checker = TractorBeamChecker.new
    coords = checker.find_square 100
    coords[:x].to_i32 * 10000 + coords[:y].to_i32
  end

  # 250020
  def self.part2_test
    checker = TractorBeamChecker.new
    checker.map.import File.read("inputs/test/19-2")
    coords = checker.find_square 10
    coords[:x].to_i32 * 10000 + coords[:y].to_i32
  end 

end

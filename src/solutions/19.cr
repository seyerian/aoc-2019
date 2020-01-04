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

end

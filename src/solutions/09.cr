class Aoc2019::Nine < Aoc2019::Solution

  def self.part1
    boost = File.read("inputs/09")
    comp = IntcodeComputer.new boost
    comp.input = ->(ic : IntcodeComputer) { Int64.new(1) }
    comp.run
    comp.outputs.last
  end

  def self.part1_test1
    program = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99"
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { Int64.new(0) }
    comp.run
    comp.outputs
  end

  def self.part1_test2
    program = "1102,34915192,34915192,7,4,7,99,0"
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { Int64.new(0) }
    comp.run
    comp.outputs.last
  end

  def self.part1_test3
    program = "104,1125899906842624,99"
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { Int64.new(0) }
    comp.run
    comp.outputs.last
  end

  def self.part2
    boost = File.read("inputs/09")
    comp = IntcodeComputer.new boost
    comp.input = ->(ic : IntcodeComputer) { Int64.new(2) }
    comp.run
    comp.outputs.last
  end

  def self.part2_test1
  end
  
end

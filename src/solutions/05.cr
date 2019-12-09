class Aoc2019::Five < Aoc2019::Solution

  def self.part1
    program = File.read("inputs/05")
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { 1.to_i64 }
    comp.run
    comp.outputs.last
  end

  def self.part2
    program = File.read("inputs/05")
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { 5.to_i64 }
    comp.run
    comp.outputs.last
  end

  def self.part2_test_compare(program_name : String, input : Int32)
    program = 
      case program_name
      when "one" then "3,9,8,9,10,9,4,9,99,-1,8"
      when "two" then "3,9,7,9,10,9,4,9,99,-1,8"
      when "three" then "3,3,1108,-1,8,3,4,3,99"
      when "four" then "3,3,1107,-1,8,3,4,3,99"
      else ""
      end
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { input.to_i64 }
    comp.run
    comp.outputs.last
  end

  def self.part2_test_jump(program_name : String, input : Int32)
    program = 
      case program_name
      when "one" then "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
      when "two" then "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
      else ""
      end
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { input.to_i64 }
    comp.run
    comp.outputs.last
  end

  def self.part2_test_larger
    # The program will then output 999 if the input value is below 8,
    # output 1000 if the input value is equal to 8, or output 1001 if the input value is greater than 8.
    program = File.read("inputs/test/05-larger")
    comp = IntcodeComputer.new program
    comp.input = ->(ic : IntcodeComputer) { 100.to_i64 }
    comp.output = ->(ic : IntcodeComputer, o : Int32) {
      puts("\n  OUTPUT: #{o}\n\n")
      true
    }
    comp.run
  end

end

class Aoc2019::Two < Aoc2019::Solution
  def self.part1
    program = File.read("inputs/02")
    comp = IntcodeComputer.new program
    comp.memory[1] = 12.to_i64
    comp.memory[2] = 2.to_i64
    comp.run

    comp.memory[0]
  end

  def self.part2
    program = File.read("inputs/02")

    (1..99).each do |noun|
      (1..99).each do |verb|
        comp = IntcodeComputer.new program
        comp.memory[1] = noun.to_i64
        comp.memory[2] = verb.to_i64
        comp.run
        if comp.memory[0] == 19690720
          return 100 * noun + verb
        end
      end
    end
  end

  def self.part1_test
    program = "1,9,10,3,2,3,11,0,99,30,40,50"
    comp = IntcodeComputer.new program
    comp.run
    comp.memory[0]
  end

end

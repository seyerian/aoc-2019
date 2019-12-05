class Aoc2019::Two < Aoc2019::Solution
  def self.part1
    program = File.read_lines("inputs/02")[0].split(',').map{|s|s.to_i32}

    program[1] = 12
    program[2] = 2

    comp = IntcodeComputer.new(program)
    comp.run

    puts comp.memory[0]

  end

  def self.part2
    program = File.read_lines("inputs/02")[0].split(',').map{|s|s.to_i32}

    (1..99).each do |noun|
      (1..99).each do |verb|
        tmp = program.dup
        tmp[1] = noun
        tmp[2] = verb
        comp = IntcodeComputer.new(tmp)
        comp.run
        if comp.memory[0] == 19690720
          puts 100 * noun + verb
        end
      end
    end
  end

end

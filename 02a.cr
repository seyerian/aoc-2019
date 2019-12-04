require "./intcode_computer"

program = File.read_lines("02a-input")[0].split(',').map{|s|s.to_i32}

program[1] = 12
program[2] = 2

comp = IntcodeComputer.new(program)
comp.run

puts comp.memory[0]

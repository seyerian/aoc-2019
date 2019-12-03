require "./intcode_computer"

program = File.read_lines("2a-input")[0].split(',').map{|s|s.to_i32}

(1..99).each do |noun|
  (1..99).each do |verb|
    tmp = program.dup
    tmp[1] = noun
    tmp[2] = verb
    comp = IntcodeComputer.new(tmp)
    comp.run
    if comp.memory[0] == 19690720
      puts 100 * noun + verb
      exit
    end
  end
end

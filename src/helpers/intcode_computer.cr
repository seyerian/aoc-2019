class IntcodeComputer
  property memory
  def initialize(@memory : Array(Int32))
  end
  def run
    p = 0
    while (i = memory[p]) != 99
      case i
      when 1 # add
        a1,a2,a3 = memory[p+1], memory[p+2], memory[p+3]
        memory[a3] = memory[a1] + memory[a2]
        p += 4
      when 2 # mult
        a1,a2,a3 = memory[p+1], memory[p+2], memory[p+3]
        memory[a3] = memory[a1] * memory[a2]
        p += 4
      end
    end
  end
end

class Aoc2019::TwentyOne < Aoc2019::Solution

  class Springdroid
    def initialize(@ending_command : String)
      unless ["WALK","RUN"].includes? @ending_command
        raise "ending command must be WALK or RUN"
      end
      @registers =
        case @ending_command
        when "WALK"
          ['A','B','C','D','T','J']
        when "RUN"
          ['A','B','C','D','E','F','G','H','I','T','J']
        else [] of Char
        end
      @script = Array(String).new
      @computer = IntcodeComputer.new File.read("inputs/21")
    end

    def and(x : Symbol, y : Symbol)
      x, y = process_instruction_args x, y
      @script << "AND #{x} #{y}"
    end

    def not(x : Symbol, y : Symbol)
      x, y = process_instruction_args x, y
      @script << "NOT #{x} #{y}"
    end

    def or(x : Symbol, y : Symbol)
      x, y = process_instruction_args x, y
      @script << "OR #{x} #{y}"
    end

    private def process_instruction_args(x : Symbol, y : Symbol)
      x = x.to_s.upcase.chars.first
      y = y.to_s.upcase.chars.first
      unless ['T', 'J'].includes? y
        raise "arg 2 must be writable register--T or J"
      end
      raise "invalid register for arg 1" unless @registers.includes? x
      raise "invalid register for arg 2" unless @registers.includes? y
      [x, y]
    end

    def start
      script = @script.clone
      script << @ending_command
      script_s = script.join '\n'
      script_s += '\n'
      script_chars = script_s.chars
      @computer.reset
      @computer.input = ->(ic : IntcodeComputer) { script_chars.shift.ord.to_i64 }
      outputs = Array(Int64).new
      @computer.output = ->(ic : IntcodeComputer, o : Int64) { outputs << o; true }
      @computer.run
      if outputs.size > 0
        if outputs.last > UInt8::MAX # hull damage
          return outputs.last 
        end
      end
      map = Map.new ['@','.','#']
      map.import outputs.map(&.chr).join
      map.draw
      false
    end
  end

  def self.part1
    sd = Springdroid.new "WALK"
    # if hole at A, jump
    sd.not :a, :j # jump if hole at A, else not jump. important that jump is initially set false. could be true from previous execution.
    # if hole at B, jump
    sd.not :b, :t # t = hole at B
    sd.or :t, :j # jump if hole at B or already jumping
    # if hole at C, jump
    sd.not :c, :t # t = hole at C
    sd.or :t, :j # jump if hole at C or already jumping
    # if ground at D, jump if already jumping due to hole
    sd.not :d, :t # t = hole at D
    sd.not :t, :t # t = ground at D
    sd.and :t, :j
    sd.start
  end

  def self.part2
    sd = Springdroid.new "RUN"
    # if hole at A, jump
    sd.not :a, :j # jump if hole at A, else not jump. important that jump is initially set false. could be true from previous execution.
    # if hole at B, jump
    sd.not :b, :t # t = hole at B
    sd.or :t, :j # jump if hole at B or already jumping
    # if hole at C, jump
    sd.not :c, :t # t = hole at C
    sd.or :t, :j # jump if hole at C or already jumping
    # if not both hole at E (next walk spot) and hole at H (next landing spot), ok to jump
    sd.not :e, :t # t = hole at E
    sd.not :t, :t # t = ground at E
    sd.or :h, :t # t = ground at E or ground at H, i.e. NOT (hole at E AND hole at H) # !(hole AND hole) = ground OR ground
    sd.and :t, :j
    # if ground at D, ok to jump
    sd.not :d, :t # t = hole at D
    sd.not :t, :t # t = ground at D
    sd.and :t, :j

    sd.start
  end

end

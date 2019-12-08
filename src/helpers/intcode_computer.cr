alias ICData = Hash( Symbol, String | Int32 | IntcodeComputer )

class IntcodeComputer
  @program : Array(Int32)
  property memory : Array(Int32)
  property data : ICData
  private property pointer : Int32
  private property halt : Bool
  setter input : Proc(IntcodeComputer, Int32)
  getter input_count : Int32
  setter output : Proc(IntcodeComputer, Int32, Bool)
  getter outputs : Array(Int32)

  def initialize( program_string : String, @data = ICData.new )
    @program = program_string.split(',').map{|s|s.to_i32}
    @memory = @program.dup
    @pointer = 0
    @halt = false
    @debug = false
    @input = ->(ic : IntcodeComputer) { 0 }
    @input_count = 0
    @output = ->(ic : IntcodeComputer, o : Int32) { false }
    @outputs = [] of Int32
  end

  #debug "#{inst}|ADD/#{modes}<#{p}>: #{vals[0]}[#{memory[p1]}]<#{p1}> + #{vals[1]}[#{memory[p2]}]<#{p2}> => #{memory[a]}[#{a}]<#{p3}>"

  def op_add(mode_string)
    vals = get_values( mode_string, 3 )
    write_address = memory[pointer+3]
    memory[ write_address ] = vals[0] + vals[1]
    @pointer += 4
  end

  def op_multiply(mode_string)
    vals = get_values( mode_string, 3 )
    write_address = memory[pointer+3]
    memory[ write_address ] = vals[0] * vals[1]
    @pointer += 4
  end
  
  def op_store(mode_string)
    #vals = get_values( mode_string, 1 )
    write_address = memory[pointer+1]
    memory[ write_address ] = input
    @pointer += 2
  end

  def op_output(mode_string)
    vals = get_values( mode_string, 1 )
    @pointer += 2
    output vals[0]
  end

  def op_jump_if_true(mode_string)
    vals = get_values( mode_string, 2 )
    @pointer = vals[0].zero? ? pointer + 3 : vals[1]
  end

  def op_jump_if_false(mode_string)
    vals = get_values( mode_string, 2 )
    @pointer = vals[0].zero? ? vals[1] : @pointer + 3
  end

  def op_less_than(mode_string)
    vals = get_values( mode_string, 3 )
    write_address = memory[pointer+3]
    memory[ write_address ] = vals[0] < vals[1] ? 1 : 0
    @pointer += 4
  end

  def op_equals(mode_string)
    vals = get_values( mode_string, 3 )
    write_address = memory[pointer+3]
    memory[ write_address ] = vals[0] == vals[1] ? 1 : 0
    @pointer += 4
  end

  def reset
    @pointer = 0
    @halt = false
  end
   
  def run
    until halt
      inst = memory[pointer].to_s
      opcode = inst[ inst.size-2, 2 ].to_i
      mode_string = inst.rchop.rchop # opcode is 2 digits
      case opcode
      when 1 then op_add(mode_string)
      when 2 then op_multiply(mode_string)
      when 3 then op_store(mode_string)
      when 4 then op_output(mode_string)
      when 5 then op_jump_if_true(mode_string)
      when 6 then op_jump_if_false(mode_string)
      when 7 then op_less_than(mode_string)
      when 8 then op_equals(mode_string)
      when 99
        @halt = true
        @pointer += 1
      end
    end
    true
  end

  private def get_values(mode_string : String, num_parameters : Int8)
    parameters = num_parameters.times.reduce([] of Int32) do |arr, i|
      arr.push( memory[pointer + i + 1] )
      arr
    end
    modes = mode_string.reverse.ljust( num_parameters, '0' )
    values = modes.chars.map_with_index do |mode, i|
      case mode
      when '0' # position
        memory[ parameters[i] ]
      when '1' # immediate
        parameters[i]
      end || 0
    end
    values
  end

  private def input
    @input_count += 1
    @input.call(self)
  end

  private def output(value : Int32)
    @outputs << value
    @output.call(self, value)
  end

  def debug(value : (Object), name = "")
    return if !@debug
    if name.size==0
      puts value
    else
      puts "#{name}=#{value.inspect}"
    end
  end

end

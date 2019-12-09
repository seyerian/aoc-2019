alias ICData = Hash( Symbol, String | Int32 | Int64 | IntcodeComputer )

class IntcodeComputer
  @program : Array(Int64)
  property memory : Array(Int64)
  property data : ICData
  private property pointer : Int64
  private property halt : Bool
  private property relative_base : Int32
  setter input : Proc(IntcodeComputer, Int64)
  getter input_count : Int64
  setter output : Proc(IntcodeComputer, Int64, Bool)
  getter outputs : Array(Int64)

  def initialize( program_string : String, @data = ICData.new )
    @program = program_string.split(',').map{|s|s.to_i64}
    @memory = Array(Int64).new(100000, 0)
    @program.dup.each.with_index do |v,i|
      @memory[i] = v
    end

    @debug = false

    @pointer = 0
    @relative_base = 0
    @input_count = 0
    @halt = false

    @input = ->(ic : IntcodeComputer) { Int64.new(0) }
    @output = ->(ic : IntcodeComputer, o : Int64) { false }
    @outputs = [] of Int64
  end

  def reset
    @relative_base = 0
    @pointer = 0
    @input_count = 0
    @halt = false
  end

  #debug "#{inst}|ADD/#{modes}<#{p}>: #{vals[0]}[#{memory[p1]}]<#{p1}> + #{vals[1]}[#{memory[p2]}]<#{p2}> => #{memory[a]}[#{a}]<#{p3}>"

  def op_add(mode_string)
    vals = get_values( mode_string, 3, 2 )
    write vals[2], vals[0] + vals[1]
    set_pointer pointer + 4
  end

  def op_multiply(mode_string)
    vals = get_values( mode_string, 3, 2 )
    write vals[2], vals[0] * vals[1]
    set_pointer pointer + 4
  end
  
  def op_store(mode_string)
    vals = get_values( mode_string, 1, 0 )
    write vals[0], input
    set_pointer pointer + 2
  end

  def op_output(mode_string)
    vals = get_values( mode_string, 1 )
    set_pointer pointer + 2
    output vals[0].to_i64
  end

  def op_jump_if_true(mode_string)
    vals = get_values( mode_string, 2 )
    set_pointer vals[0].zero? ? pointer + 3 : vals[1]
  end

  def op_jump_if_false(mode_string)
    vals = get_values( mode_string, 2 )
    set_pointer vals[0].zero? ? vals[1] : pointer + 3
  end

  def op_less_than(mode_string)
    vals = get_values( mode_string, 3, 2 )
    write vals[2], vals[0] < vals[1] ? 1 : 0
    set_pointer pointer + 4
  end

  def op_equals(mode_string)
    vals = get_values( mode_string, 3, 2 )
    write vals[2], vals[0] == vals[1] ? 1 : 0
    set_pointer pointer + 4
  end

  def op_relative_base_offset(mode_string)
    vals = get_values( mode_string, 1 )
    self.relative_base = relative_base + vals[0]
    set_pointer pointer + 2
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
      when 9 then op_relative_base_offset(mode_string)
      when 99
        self.halt = true
        set_pointer pointer + 1
      end
    end
    true
  end

  private def get_values(mode_string : String, num_params : Int8, address_param : Int8 = -1)
    parameters = num_params.times.reduce([] of Int64) do |arr, i|
      arr.push( memory[pointer + i + 1] )
      arr
    end
    modes = mode_string.reverse.ljust( num_params, '0' )
    values = modes.chars.map_with_index do |mode, i|
      case mode
      when '0' # position
        if address_param == i
          parameters[i]
        else
          memory[ parameters[i] ]
        end
      when '1' # immediate
        parameters[i]
      when '2' # relative
        if address_param == i
          parameters[i] + relative_base
        else
          memory[ parameters[i] + relative_base ]
        end
      end || 0
    end
    values
  end

  private def write(address : Int32|Int64, value : Int32|Int64)
    memory[address] = value.to_i64
  end

  private def set_pointer(value : Int32|Int64)
    self.pointer = value.to_i64
  end

  private def input
    @input_count += 1
    @input.call(self)
  end

  private def output(value : Int64)
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

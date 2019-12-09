class Aoc2019::Seven < Aoc2019::Solution

  def self.configure_amps(phase_sequence : Array(Int32), program : String)
    a = IntcodeComputer.new program, ICData{ :name => "A", :ps => phase_sequence.shift }
    b = IntcodeComputer.new program, ICData{ :name => "B", :ps => phase_sequence.shift, :feeder => a }
    c = IntcodeComputer.new program, ICData{ :name => "C", :ps => phase_sequence.shift, :feeder => b }
    d = IntcodeComputer.new program, ICData{ :name => "D", :ps => phase_sequence.shift, :feeder => c }
    e = IntcodeComputer.new program, ICData{ :name => "E", :ps => phase_sequence.shift, :feeder => d }
    a.data[:feeder] = e

    amps = [a,b,c,d,e]

    amps.each do |amp|
      amp.input = ->(ic : IntcodeComputer) {
        val = 
          if ic.input_count == 1
            ps = ic.data[:ps]
            ps.is_a?(Int32) ? ps : 0
          elsif ic.input_count == 2 && ic == a
            0
          else
            feeder = ic.data[:feeder]
            if feeder.is_a?(IntcodeComputer)
              feeder.outputs.last || 0
            else
              0
            end
          end
        val.to_i64
      }
      amp.output = ->(ic : IntcodeComputer, o : Int64) {
        to_feed = amps.find{|amp|amp.data[:feeder] == ic}
        if !to_feed.nil?
          to_feed.run 
          true
        else
          false
        end
      }
    end

    a.run
    e.outputs.last
  end

  def self.part1
    program = File.read("inputs/07")
    greatest_signal = 0
    [0,1,2,3,4].each_permutation do |permutation|
      signal = configure_amps permutation, program
      if signal > greatest_signal
        greatest_signal = signal
      end
    end
    greatest_signal
  end

  def self.part1_test1
    program = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
    configure_amps [4,3,2,1,0], program
  end

  def self.part1_test2
    program = "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
    configure_amps [0,1,2,3,4], program
  end

  def self.part1_test3
    program = "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
    configure_amps [1,0,4,3,2], program
  end

  def self.part2
    program = File.read("inputs/07")
    greatest_signal = 0
    [5,6,7,8,9].each_permutation do |permutation|
      signal = configure_amps permutation, program
      if signal > greatest_signal
        greatest_signal = signal
      end
    end
    greatest_signal
  end

  def self.part2_test1
    program = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
    configure_amps [9,8,7,6,5], program
  end

  def self.part2_test2
    program = "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
    configure_amps [9,7,8,5,6], program
  end

end

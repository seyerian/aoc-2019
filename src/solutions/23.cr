class Aoc2019::TwentyThree < Aoc2019::Solution
  alias Packet = NamedTuple(address: Int64, x: Int64, y: Int64)
  class ICNetwork
    NAT_ADDRESS = 255_i64
    private getter packet_channel
    private property queue, running_computers
    def initialize(@num_computers : Int32)
      @packet_channel = Channel(Packet).new
      @queue = [] of Packet
      @running_computers = Hash(IntcodeComputer, Channel(Nil)).new
      @nat_packet = nil.as(Nil|Packet)
      @nat_packets_sent = [] of Packet
    end

    def run
      @num_computers.times { |i| spawn_computer(i.to_i64) }
      spawn do
        loop do
          running_computers.each do |computer, channel|
            begin
              channel.send(nil) 
            rescue Channel::ClosedError
            end
          end
          nat_check_idle
          #if packet = packet_channel.receive
          #  queue << packet
          #end
        end
      end
      sleep
    end

    def send(packet : Packet)
      valid_addresses = (0...@num_computers).to_a + [NAT_ADDRESS]
      if valid_addresses.includes? packet[:address]
        if packet[:address] == NAT_ADDRESS
          # PART 1
          #puts packet[:y]
          #exit
          # PART 2
          @nat_packet = packet
        else
          #packet_channel.send packet
          queue << packet
        end
      end
    end

    def nat_check_idle
      idle_computers = running_computers.keys.select{|ic|ic.data_i64.has_key?(:idle)}
      if idle_computers.size == @num_computers && queue.empty?
        if packet = @nat_packet
          release = {address: 0_i64, x: packet[:x], y: packet[:y]}
          send(release)
          @nat_packets_sent << release
          if @nat_packets_sent.size > 0
            y_values = @nat_packets_sent.map{|p|p[:y]}
            if first_dup_y = y_values.find{|y|y_values.count(y) == 2}
              puts first_dup_y
              exit
            end
          end
        end
      end
    end

    def receive(address : Int64)
      packet = queue.find {|p| p[:address] == address }
      queue.delete(packet) if packet
      packet
    end

    def spawn_computer(address : Int64)
      data = Hash(Symbol, Int64).new
      data[:address] = address
      computer = IntcodeComputer.new File.read("inputs/23"), data_i64: data
      computer.input = ->(ic : IntcodeComputer) {
        address = ic.data_i64[:address]
        ic.data_i64.delete :idle
        # set address as first input
        unless ic.data_i64.has_key? :set_address
          ic.data_i64[:set_address] = 1
          return ic.data_i64[:address]
        end
        # if a packet was already received, y value sent after x
        if in_y = ic.data_i64.fetch(:in_y, nil)
          ic.data_i64.delete :in_y
          return in_y
        else
          if packet = receive address
            # store y value for next input
            ic.data_i64[:in_y] = packet[:y]
            return packet[:x]
          end
        end

        # return if no packet received
        ic.data_i64[:idle] = 1_i64
        return -1.to_i64
      }
      computer.output = ->(ic : IntcodeComputer, o : Int64) {
        d = ic.data_i64
        case
        when d.has_key?(:out_address) && d.has_key?(:out_x)
          send({address: d[:out_address], x: d[:out_x], y: o})
          d.delete :out_address
          d.delete :out_x
        when d.has_key?(:out_address) && !d.has_key?(:out_x)
          d[:out_x] = o
        else
          d[:out_address] = o
        end
        true
      }
      computer.pre_hook = ->(ic : IntcodeComputer) {
        running_computers[ic].receive
        true
      }
      computer.post_hook = ->(ic : IntcodeComputer) {
        Fiber.yield
        true
      }
      ->(ic : IntcodeComputer) {
        spawn do
          channel = Channel(Nil).new
          running_computers[computer] = channel
          computer.run
          channel.close
          running_computers.delete computer
        end
      }.call(computer)
    end

  end
end

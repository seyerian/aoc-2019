class Aoc2019::Thirteen < Aoc2019::Solution

  class ArcadeCabinet
    property display, autoplay
    getter score
    getter screen

    enum Tile : Int8; Empty; Wall; Block; Paddle; Ball; end

    def initialize(game : String, quarters = 0)
      @screen = Hash(Int32, Hash(Int32, Int8)).new
      @score = Int64.new(0)
      @autoplay = false
      @display = true
      @ball_position = {x: 0, y: 0}
      @paddle_position = {x: 0, y: 0}

      data = ICData.new
      data[:x] = 0
      data[:y] = 0
      @computer = IntcodeComputer.new game, data
      @computer.memory[0] = quarters.to_i64 if quarters > 0
      @computer.input = ->(ic : IntcodeComputer) {
        case step
        when 'q'
          puts "Quitting..."
          exit
        when 'a'
          Int64.new(-1)
        when 'd'
          Int64.new(1)
        else
          Int64.new(0)
        end
      }
      @computer.output = ->(ic : IntcodeComputer, o : Int64) {
        x, y = ic.data[:x], ic.data[:y]
        return false if !x.is_a?(Int)
        return false if !y.is_a?(Int)
        x = x.to_i32
        y = y.to_i32
        case ic.outputs.size % 3
        when 0
          if x == -1 # segment display
            @score = o
          else
            @screen[y] = Hash(Int32, Int8).new if !@screen.has_key?(y)
            @screen[y][x] = o.to_i8
            case Tile.new(o.to_i8)
            when Tile::Ball
              @ball_position = {x: x, y: y}
            when Tile::Paddle
              @paddle_position = {x: x, y: y}
            end
          end
        when 2 then ic.data[:y] = o
        else ic.data[:x] = o
        end
        true
      }
    end

    def run; @computer.run; end

    def step
      draw_display if display
      get_input
    end

    private def get_input
      if @autoplay
        case
        when @ball_position[:x] < @paddle_position[:x]
          'a'
        when @ball_position[:x] > @paddle_position[:x]
          'd'
        else
          'w'
        end
      else
        STDIN.raw do |io|
          io.noecho!
          io.read_char
        end
      end
    end

    private def draw_display
      `clear`
      fill
      @screen.each do |y, row|
        row.each do |x, tile|
          print case Tile.new(tile)
            when Tile::Empty then ' '
            when Tile::Wall then 'W'
            when Tile::Block then 'B'
            when Tile::Paddle then '-'
            when Tile::Ball then 'O'
            end
        end
        puts
      end
      puts @score
    end

    private def fill
      all_y = @screen.keys
      all_x = @screen.values.flatten.map{|h|h.keys}.flatten
      all_y.min.to(all_y.max) do |y|
        all_x.min.to(all_x.max) do |x|
          @screen[y] = Hash(Int32, Int8).new if !@screen.has_key?(y)
          @screen[y][x] = Tile::Empty.value.to_i8 if !@screen[y].has_key?(x)
        end
      end
    end
  end

  def self.part1
    cabinet = ArcadeCabinet.new File.read("inputs/13")
    cabinet.run
    #cabinet.display
    cabinet.screen.values.flatten.map{|h|h.values}.flatten.count do |v|
      v == ArcadeCabinet::Tile::Block.value
    end
  end
  
  #def self.part1_test
  #  cabinet = ArcadeCabinet.new
  #  cabinet.run
  #  cabinet.display
  #end

  def self.part2
    cabinet = ArcadeCabinet.new File.read("inputs/13"), 2
    cabinet.autoplay = true
    cabinet.display = false
    cabinet.run
    cabinet.score
  end
end

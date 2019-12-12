class Aoc2019::Eleven < Aoc2019::Solution

  class EmergencyHullPaintingRobot
    BLACK = Int8.new 0
    WHITE = Int8.new 1
    LEFT = Int8.new 0
    RIGHT = Int8.new 1

    getter hull
    property x, y
    getter first_white_x, first_white_y

    def initialize(program_string : String)
      @first_white_x = nil.as(Nil|Int32)
      @first_white_y = nil.as(Nil|Int32)
      @directions = [
        {x: 0, y: -1}, # up
        {x: 1, y: 0}, # right
        {x: 0, y: 1}, # down
        {x: -1, y: 0}, # left
      ]
      @x = 0
      @y = 0
      @hull = Hash(Int32, Hash(Int32, Int8)).new

      @brain = IntcodeComputer.new(program_string)
      @brain.input = ->(ic : IntcodeComputer) {
        @hull[@y] = Hash(Int32, Int8).new if !@hull.has_key?(@y)
        @hull[@y][@x] = BLACK if !@hull[@y].has_key?(@x)
        @hull[@y][@x].to_i64
      }
      @brain.output = ->(ic : IntcodeComputer, o : Int64) {
        case
        when ic.outputs.size.odd?
          paint o.to_i8
          true
        when ic.outputs.size.even?
          turn o.to_i8
          move
          true
        else false
        end
      }
    end

    def run
      @brain.reset
      @brain.run
    end

    def paint(color : Int8)
      if color == WHITE && @first_white_y.nil?
        @first_white_y = @y
        @first_white_x = @x
      end
      @hull[@y] = Hash(Int32, Int8).new if !@hull.has_key?(@y)
      @hull[@y][@x] = color
    end

    def turn(direction : Int8)
      case direction
      when LEFT
        @directions.rotate!(3)
      when 
        @directions.rotate!(1)
      end
    end

    def move
      dir = @directions.first
      @x += dir[:x]
      @y += dir[:y]
      true
    end

    def paint_all_black
      all_y = @hull.keys
      all_x = @hull.values.flatten.map{|h|h.keys}.flatten
      all_y.min.to(all_y.max) do |y|
        all_x.min.to(all_x.max) do |x|
          @hull[y] = Hash(Int32, Int8).new if !@hull.has_key?(y)
          @hull[y][x] = BLACK
        end
      end
    end

    def print
      all_y = @hull.keys
      all_x = @hull.values.flatten.map{|h|h.keys}.flatten
      all_y.min.to(all_y.max) do |y|
        all_x.min.to(all_x.max) do |x|
          @hull[y] = Hash(Int32, Int8).new if !@hull.has_key?(y)
          @hull[y][x] = BLACK if !@hull[y].has_key?(x)
        end
      end
      all_y.min.to(all_y.max) do |y|
        all_x.min.to(all_x.max) do |x|
          print case @hull[y][x]
            when WHITE
              '@'
            when BLACK
              '.'
            else '?'
            end
        end
        puts
      end
    end
  end

  def self.part1
    robot = EmergencyHullPaintingRobot.new File.read("inputs/11")
    robot.run
    robot.hull.values.map{|h|h.values}.flatten.size
  end

  def self.part2
    robot = EmergencyHullPaintingRobot.new File.read("inputs/11")
    robot.run
    if !(y = robot.first_white_y).nil?
      robot.y = y
    end
    if !(x = robot.first_white_x).nil?
      robot.x = x
    end
    robot.paint_all_black
    robot.paint EmergencyHullPaintingRobot::WHITE
    robot.run
    robot.print
  end

end

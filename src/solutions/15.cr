class Aoc2019::Fifteen < Aoc2019::Solution

  class RepairDroid
    private property pos : NamedTuple(x: Int32, y: Int32)
    enum Dir : Int8
      North = 1
      South = 2
      West = 3
      East = 4
    end
    enum Status : Int8
      Wall = 0
      Moved = 1
      OxygenSystem = 2
    end
    enum Tile : Int8
      Wall = 0
      Floor = 1
      OxygenSystem = 2
      Droid = 3
    end
    def initialize(program : String)
      @last_pos = {x: 0, y: 0}
      @pos = {x: 0, y: 0}
      @map = Map.new({
        Tile::Wall.value => '#',
        Tile::Floor.value => '.',
        Tile::OxygenSystem.value => 'X',
        Tile::Droid.value => 'D'
      })
      @moves = Array(Int8).new
      @computer = IntcodeComputer.new program
      @computer.input = ->(ic : IntcodeComputer) {
        # continue in same direction as before if didn't hit a wall
        a_pos = attempted_pos
        if @moves.size > 0
          unless (last_move = @moves.last).nil?
            if @pos == a_pos
              @moves << last_move
              return last_move.to_i64
            end
          end
        end
        move = Dir.values.sample.value # random direction for now
        @moves << move
        move.to_i64
      }
      @computer.output = ->(ic : IntcodeComputer, o : Int64) {
        @last_pos = @pos
        a_pos = attempted_pos
        return false if a_pos.nil?
        case Status.new( Int8.new(o) )
        when Status::Wall
          @map.update(a_pos[:x], a_pos[:y], Tile::Wall.value)
        when Status::Moved
          @map.update(a_pos[:x], a_pos[:y], Tile::Floor.value)
          @pos = a_pos.dup
        when Status::OxygenSystem
          @map.update(a_pos[:x], a_pos[:y], Tile::OxygenSystem.value)
          @pos = a_pos.dup
        end
        @map.draw @pos[:x], @pos[:y]
        true
      }
    end

    def attempted_pos
      return nil if @moves.size == 0
      last = @moves.last
      return nil if last.nil?
      case Dir.new( last )
      when Dir::North
        {x: @last_pos[:x], y: @last_pos[:y]-1}
      when Dir::South
        {x: @last_pos[:x], y: @last_pos[:y]+1}
      when Dir::West
        {x: @last_pos[:x]-1, y: @last_pos[:y]}
      when Dir::East
        {x: @last_pos[:x]+1, y: @last_pos[:y]}
      end
    end

    def run
      @computer.run
    end
  end

  def self.part1
    droid = RepairDroid.new File.read("inputs/15")
    droid.run
  end

end

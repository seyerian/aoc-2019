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
      @os_pos = {x: 0, y: 0}
      @map.update(0,0, Tile::Floor.value)
      @moves = Array(Int8).new
      @computer = IntcodeComputer.new program
      @computer.input = ->(ic : IntcodeComputer) {
        move = choose_direction
        @moves << move
        move.to_i64
      }
      @computer.output = ->(ic : IntcodeComputer, o : Int64) {
        @last_pos = @pos
        a_pos = attempted_position
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
          @os_pos = a_pos.dup
        end
        #@map.draw @pos[:x], @pos[:y]
        true
      }
    end

    def random_direction(msg : String)
      puts "RANDOM - #{msg}"
      Dir.values.sample.value 
    end

    def choose_direction
      path = @map.find_path(@pos[:x], @pos[:y]) do |node|
        @map.at(node.x, node.y).nil? # find a space not explored
      end
      if path.nil?
        path_to_os = @map.find_path(0,0) do |node|
          node.x == @os_pos[:x] && node.y == @os_pos[:y]
        end
        if !path_to_os.nil?
          puts "===PART 1==="
          puts path_to_os.size - 1
          puts "===PART 2==="
          distances_to_open_locs = [] of Int32
          @map.all_y.min.to(@map.all_y.max) do |y|
            @map.all_x.min.to(@map.all_x.max) do |x|
              if @map.at(x,y)==Tile::Floor.value
                path = @map.find_path(@os_pos[:x], @os_pos[:y]) do |node|
                  node.x == x && node.y == y
                end
                if !path.nil?
                  distances_to_open_locs << path.size - 1
                end
              end
            end
          end
          puts distances_to_open_locs.sort.last
          exit
        end
      end
      return random_direction("path nil") if path.nil?
      first = path[1]
      return random_direction("path empty") if first.nil?
      case
      when first.x == @pos[:x] && first.y < @pos[:y]
        Dir::North.value
      when first.x == @pos[:x] && first.y > @pos[:y]
        Dir::South.value
      when first.x < @pos[:x] && first.y == @pos[:y]
        Dir::West.value
      when first.x > @pos[:x] && first.y == @pos[:y]
        Dir::East.value
      else
        random_direction("path ???")
      end
    end

    def attempted_position
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

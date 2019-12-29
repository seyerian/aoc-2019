class Aoc2019::Eighteen < Aoc2019::Solution

  abstract struct Item
    def_clone
    getter x, y, char
    def initialize(@x : Int16, @y : Int16, @char : Char)
    end
  end

  struct Key < Item; end

  struct Door < Item
    property key : Key|Nil
  end

  class KeySolver
    def_clone
    getter? done : Bool
    getter steps : UInt32
    property keys : Array(Key)
    property doors : Array(Door)
    property key_sought : Key|Nil
    getter last_key : Key|Nil
    getter map, pos, order
    def initialize(map_string : String)
      chars = Array(Char).new
      chars.concat ['#','.','@']
      chars.concat ('a'..'z').to_a
      chars.concat ('A'..'Z').to_a
      @map = Map.new chars
      @map.import map_string
      @keys = Array(Key).new
      @doors = Array(Door).new
      @pos = {x: 0_i16, y: 0_i16}
      @done = false
      @steps = 0
      @order = ""
      @available_keys_paths = Hash(Char, Array(Map::PathNode)).new
      setup
    end

    def fill_dead_ends_and_trim_map
      fill_dead_ends
      trim_map
    end

    def fill_dead_ends
      #map.draw(pos[:x], pos[:y], '@')
      #puts "#fill_dead_ends"
      path = @map.find_path(@pos[:x], @pos[:y]) do |node|
        floor = @map.get_char(node.x, node.y) == '.'
        wall_count = @map.neighbors(node.x, node.y).count do |h|
          h[:char] == '#'
        end
        floor && wall_count == 3
      end
      return if path.nil?
      path.shift # current position
      path.reverse.each do |node|
        floor = @map.get_char(node.x, node.y) == '.'
        wall_count = @map.neighbors(node.x, node.y).count do |h|
          h[:char] == '#'
        end
        if floor && wall_count == 3
          @map.set(node.x, node.y, '#')
        end
      end
      fill_dead_ends
    end

    def trim_map
      @map.each_char do |x, y, char|
        @map.unset(x, y) if char=='#'
      end
    end

    def setup
      # find self, keys, and doors on map
      @map.each do |x, y, tile|
        next if tile.nil?
        if ('a'..'z').map(&.ord).includes?(tile)
          @keys << Key.new(x, y, tile.chr)
        elsif ('A'..'Z').map(&.ord).includes?(tile)
          @doors << Door.new(x, y, tile.chr)
        elsif tile == '@'.ord
          @pos = {x: x, y: y}
          @map.set(x, y, '.')
        end
      end

      @doors.each do |door|
        @keys.each do |key|
          door.key = key if door.char.downcase == key.char
        end
      end

      @map.set_distance '#', Map::UNREACHABLE
      fill_dead_ends_and_trim_map

      build_heuristics

      ('A'..'Z').each do |char|
        @map.set_distance char, Map::UNREACHABLE
      end
    end

    def build_heuristics
      items = Array(Item).new
      items.concat(@keys)
      #items.concat(@doors)
      items.each do |item|
        path = @map.find_path(@pos[:x], @pos[:y]) do |node|
          @map.get_char(node.x, node.y) == item.char
        end
        next if path.nil?
        path.each do |node|
          @map.add_heuristic(node.x, node.y, item.char)
        end
      end
    end

    def find_available_keys
      @available_keys_paths = Hash(Char, Array(Map::PathNode)).new
      #puts "#find_available_keys #{object_id}"
      available = Array(Key).new
      @keys.each do |key|
        heuristic_checker = Proc(Map::PathNode, Bool).new do |node|
          last_key = self.last_key
          return true if last_key.nil?
          @map.check_heuristic(node.x, node.y, key.char) ||
            @map.check_heuristic(node.x, node.y, last_key.char) ||
            (@map.neighbors(node.x, node.y).count{|h|h[:char]=='.'} > 2)
        end
        path = @map.find_path(@pos[:x], @pos[:y],
                              heuristic_checker: heuristic_checker) do |node|
          [key.x, key.y] == [node.x, node.y]
        end
        next if path.nil?
        #puts "- #{key.char} - #{path.size}"
        @available_keys_paths[key.char] = path
        available << key
      end
      #puts "#{available.size} available keys"
      available
    end

    def get_key(key : Key)
      #puts "#get_key #{key.char} #{object_id}"
      #path = @map.find_path(@pos[:x], @pos[:y]) do |node|
      #  [key.x, key.y] == [node.x, node.y]
      #end
      path = @available_keys_paths[key.char]
      raise "CAN'T GET KEY #{key.char}" if path.nil?
      raise "CAN'T GET KEY #{key.char}" if path.size == 0
      final = path.last
      @pos = {x: final.x, y: final.y}
      @steps += path.size - 1
      @map.set(final.x, final.y, '.')
      @order += key.char
      @last_key = key
      @keys.delete(key)
      @doors.each do |door|
        if door.char.downcase == key.char
          @map.set(door.x, door.y, '.')
          @doors.delete(door)
        end
      end
    end

    def solve(solvers : Array(KeySolver), best_steps : UInt32)
      if steps > best_steps
        puts "not good, returning early"
        @done = true
        return
      end
      #sleep 1
      #puts "#solve #{object_id}"
      if key = key_sought
        #puts "- seeking key #{key.char}"
        get_key key
        self.key_sought = nil
        fill_dead_ends_and_trim_map
      else
        available_keys = find_available_keys
        if available_keys.size == 0
          #puts "- done"
          @done = true
        else
          self.key_sought = available_keys.shift
          available_keys.each do |key|
            clone = self.clone
            #puts "!!! CLONING solver for available key #{key.char} - #{clone.object_id}"
            clone.key_sought = clone.keys.find{|k|k.char==key.char}
            solvers << clone
          end
        end
      end
    end

  end # KeySolver

  def self.solve(map : String)
    best_steps = UInt32.new(1000000000)
    best_order = ""
    solvers = Array( Aoc2019::Eighteen::KeySolver ).new
    solver = Aoc2019::Eighteen::KeySolver.new(map)
    solvers << solver
    until solvers.empty?
      puts solvers.size
      solvers.sort_by!{|s|s.steps}.reverse!
      if solver = solvers.first #find{|s|!s.done?}
        #solver.map.draw(solver.pos[:x], solver.pos[:y], '@')
        solver.solve solvers, best_steps
        if solver.done?
          if solver.steps < best_steps
            best_steps = solver.steps
            best_order
          end
          solvers.delete solver
        end
      end
    end
    #solvers.sort_by!{|s|s.steps}
    #return false if solvers.size == 0
    #solvers.first.steps
    best_steps
  end

  def self.part1
    solve(File.read("inputs/18"))
  end

end

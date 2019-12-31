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
    property keys : Array(Key)
    property doors : Array(Door)
    getter last_key : Char|Nil
    getter map, pos, order

    struct State
      def_clone
      property steps : UInt32
      property done : Bool
      property keys : Array(Char)
      property last_key : Char|Nil
      property next_key : Char|Nil
      def initialize
        @keys = [] of Char
        @steps = 0
        @done = false
      end

      def doors_unlocked
        keys.map(&.upcase)
      end

      def order
        keys.join ""
      end
    end

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
      @key_paths = Hash(Char|Nil, Hash(Char, Int16)).new
      @key_path_blockers = Hash(Char|Nil, Hash(Char, Array(Char))).new
      setup
    end

    def fill_dead_ends_and_trim_map
      trim_map
      fill_dead_ends
    end

    def trim_map
      @map.each_char do |x, y, char|
        @map.unset(x, y) if char=='#'
      end
    end

    def fill_dead_ends
      #map.draw(pos[:x], pos[:y], '@')
      puts "#fill_dead_ends"
      path = @map.find_path(@pos[:x], @pos[:y]) do |node|
        floor = @map.get_char(node.x, node.y) == '.'
        dead_end = @map.neighbors(node.x, node.y).size == 1
        floor && dead_end
      end
      return if path.nil?
      path.shift # current position
      path.reverse.each do |node|
        floor = @map.get_char(node.x, node.y) == '.'
        dead_end = @map.neighbors(node.x, node.y).size == 1
        if floor && dead_end
          @map.unset(node.x, node.y)
        end
      end
      fill_dead_ends
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

      door_chars = ('A'..'Z').to_a 

      @key_paths[nil] = Hash(Char, Int16).new
      @key_path_blockers[nil] = Hash(Char, Array(Char)).new
      @keys.each do |key|
        @key_path_blockers[nil][key.char] = Array(Char).new
        path = @map.find_path(@pos[:x], @pos[:y]) do |node|
          @map.get_char(node.x, node.y) == key.char
        end
        next if path.nil?
        @key_paths[nil][key.char] = path.size.to_i16 - 1
        path.each do |node|
          char = @map.get_char(node.x, node.y)
          if door_chars.includes?(char)
            @key_path_blockers[nil][key.char] << char
          end
        end
      end
      @keys.each do |key|
        @key_paths[key.char] = Hash(Char, Int16).new
        @key_path_blockers[key.char] = Hash(Char, Array(Char)).new
        @keys.each do |key2|
          next if key.char==key2.char
          @key_path_blockers[key.char][key2.char] = Array(Char).new
          path = @map.find_path(key.x, key.y) do |node|
            @map.get_char(node.x, node.y) == key2.char
          end
          next if path.nil?
          @key_paths[key.char][key2.char] = path.size.to_i16 - 1
          path.each do |node|
            char = @map.get_char(node.x, node.y)
            if door_chars.includes?(char)
              @key_path_blockers[key.char][key2.char] << char
            end
          end
        end
      end
    end

    def solve
      best_steps = UInt32.new(1000000000)
      best_order = ""
      states = Array(State).new
      state = State.new
      states << state
      i = 0_u64
      until states.empty?
        i += 1
        puts "#{i} iterations, #{states.size} states queued"
        states.sort_by!{|s|s.steps}.reverse!
        if state = states.shift
          if state.done
            if state.steps < best_steps
              best_steps = state.steps
              best_order = state.order
            end
          else
            solve_state state, states, best_steps
          end
        end
      end
      best_steps
    end

    def solve_state(state : State, states : Array(State), best_steps : UInt32)
      if state.steps > best_steps
        #puts "not good, returning early"
        state.done = true
        return
      end
      #sleep 1
      #puts "#solve #{state}"
      if key = state.next_key
        #puts "- seeking key #{key}"
        state.steps += @key_paths[state.last_key][key]
        state.keys << key
        state.last_key = key
        state.next_key = nil
        states << state
      else
        #puts "#find_available_keys #{object_id}"
        available_keys = Array(Char).new
        @key_path_blockers[@last_key].each do |key2, path_blockers|
          next if state.keys.includes?(key2)
          if path_blockers.-(state.doors_unlocked).empty?
            available_keys << key2
          end
        end

        if available_keys.size == 0
          #puts "- done"
          state.done = true
          states << state
        else
          state.next_key = available_keys.shift
          states << state
          available_keys.each do |key|
            clone = state.clone
            #puts "!!! CLONING solver for available key #{key} - #{clone}"
            clone.next_key = key
            states << clone
          end
        end
      end
    end

  end # KeySolver

  def self.solve(map : String)
    Aoc2019::Eighteen::KeySolver.new(map).solve
  end

  def self.part1
    solve(File.read("inputs/18"))
  end

end

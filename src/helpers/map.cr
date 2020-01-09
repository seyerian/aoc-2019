class Map
  def_clone
  alias Position = NamedTuple(x: Int16, y: Int16)
  property? has_teleporters : Bool
  getter teleporters
  property teleport_mode : Symbol
  property teleporter_label_tiles : Array(Char)

  TELEPORTER_CHAR = '!'
  UNKNOWN_CHAR = '?'
  UNREACHABLE = Int32::MAX

  def initialize(tiles : Array(Char))
    tiles_h = Hash(Int8, Char).new
    tiles.each.with_index do |tile, i|
      tiles_h[tile.ord.to_i8] = tile
    end
    initialize tiles_h
  end

  def initialize(@tiles : Hash(Int8, Char))
    @tiles[TELEPORTER_CHAR.ord.to_i8] = TELEPORTER_CHAR
    @map = Hash(Int16, Hash(Int16, Int8)).new
    @distances = Hash(Int8, Int32).new
    @heuristics = Hash(Int16, Hash(Int16, Array(Int8))).new
    @teleporters = Hash(String, Array(Position)).new
    @teleporter_label_tiles = Array(Char).new
    @has_teleporters = false
    @teleport_mode = :default
  end

  def add_heuristic(x : Int16, y : Int16, tile : Int8|Char|Nil)
    tile = @tiles.key_for(tile) if tile.is_a? Char
    return false if tile.nil?
    @heuristics[y] = Hash(Int16, Array(Int8)).new if !@heuristics.has_key?(y)
    @heuristics[y][x] = Array(Int8).new if !@heuristics[y].has_key?(x)
    @heuristics[y][x] << tile
    true
  end

  def check_heuristic(x : Int16, y : Int16, tile : Int8|Char)
    tile = @tiles.key_for(tile) if tile.is_a? Char
    return false if tile.nil?
    return false if !@heuristics.has_key?(y)
    return false if !@heuristics[y].has_key?(x)
    @heuristics[y][x].includes? tile
  end

  def set_distance(tile : Char, distance : Int32)
    @distances[@tiles.key_for(tile)] = distance
  end

  def set_distances(distances : Hash(Int8, Int32))
    @distances = distances
  end

  private def distance(tile : Int8|Nil)
    return 1 if tile.nil? || !@distances.has_key?(tile)
    @distances[tile]
  end

  # `map` is expected to be a multi-line string, e.g. a heredoc
  def import(map : String)
    map.split("\n").each.with_index do |line, y|
      line.chars.each.with_index do |tile, x|
        next unless @tiles.values.includes?(tile)
        set x.to_i16, y.to_i16, tile
      end
    end
    setup_teleporters if has_teleporters?
  end

  def setup_teleporters
    each_char do |x, y, char|
      next unless @teleporter_label_tiles.includes?(char)
      unset x, y
      down = get_char(x, y+1)
      right = get_char(x+1, y)
      if @teleporter_label_tiles.includes?(down)
        unset x, y+1
        label = [char, down].join
        @teleporters[label] = Array(Position).new if !@teleporters.has_key?(label)
        down2 = get_char(x, y+2)
        if down2 == '.'
          @teleporters[label] << {x: x, y: y+2}
          set x, y+1, TELEPORTER_CHAR
        else
          @teleporters[label] << {x: x, y: y-1}
          set x, y, TELEPORTER_CHAR
        end
      elsif @teleporter_label_tiles.includes?(right)
        unset x+1, y
        label = [char, right].join
        @teleporters[label] = Array(Position).new if !@teleporters.has_key?(label)
        right2 = get_char(x+2, y)
        if right2 == '.'
          @teleporters[label] << {x: x+2, y: y}
          set x+1, y, TELEPORTER_CHAR
        else
          @teleporters[label] << {x: x-1, y: y}
          set x, y, TELEPORTER_CHAR
        end 
      end
    end
  end

  def count(tile : Int8|Char)
    tile = @tiles.key_for(tile) if tile.is_a? Char
    count = 0
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        count += 1 if get(x, y) == tile
      end
    end
    count
  end

  def neighbors(x : Int16, y : Int16)
    neighboring_tiles = [
      {x: 0, y: -1},
      {x: 0, y: 1},
      {x: -1, y: 0},
      {x: 1, y: 0}
    ]
    neighboring_tiles.map do |coords|
      tile = get( x + coords[:x], y + coords[:y] )
      next if tile.nil?
      {
        x: x + coords[:x],
        y: y + coords[:y],
        tile: tile,
        char: @tiles[tile]
      }
    end.compact
  end

  def find(tile : Int8|Char)
    tile = @tiles.key_for(tile) if tile.is_a? Char
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        if get(x, y) == tile
          return {x: x, y: y} 
        end
      end
    end
    nil
  end

  def unset(x : Int16, y : Int16)
    x = x.to_i16
    y = y.to_i16
    return if (x.nil? || y.nil?)
    return if !@map.has_key?(y)
    return if !@map[y].has_key?(x)
    @map[y].delete(x)
  end

  def set(x : Int16, y : Int16, tile : Int8|Char|Nil)
    tile = @tiles.key_for(tile) if tile.is_a? Char
    return false if tile.nil?
    @map[y] = Hash(Int16, Int8).new if !@map.has_key?(y)
    @map[y][x] = tile
    true
  end

  def get_char(x : Int16, y : Int16)
    if tile = get(x,y)
      @tiles[tile]
    else
      UNKNOWN_CHAR
    end
  end

  def get(x : Int16, y : Int16)
    x = x.to_i16
    y = y.to_i16
    return nil if !@map.has_key?(y)
    return nil if !@map[y].has_key?(x)
    @map[y][x]
  end

  class PathNode
    def_clone
    property x, y
    property parent : (PathNode|Nil)
    property visited : Bool
    property distance : Int32
    property level : Int8
    def initialize(@x : Int16, @y : Int16, @level : Int8 = 0)
      @visited = false
      @distance = UNREACHABLE
    end
    def neighbor_of?(node : PathNode)
      (@x-node.x).abs + (@y-node.y).abs < 2 && level == node.level
    end
    def ==(other : PathNode)
      x==other.x && y==other.y && level==other.level
    end
  end

  def teleport_between?(node1 : PathNode, node2 : PathNode)
    return false if !has_teleporters?
    return false if node1.x==node2.x && node1.y==node2.y
    linked = @teleporters.any? do |code, positions|
      positions.includes?({x: node1.x, y: node1.y}) && positions.includes?({x: node2.x, y: node2.y})
    end
    return false unless linked
    case teleport_mode
    when :default
      true
    when :levels
      middle_x = all_x.max / 2
      middle_y = all_y.max / 2

      node1_inner =
        case
        when get_char(node1.x + 1, node1.y)==TELEPORTER_CHAR && node1.x < middle_x then true
        when get_char(node1.x - 1, node1.y)==TELEPORTER_CHAR && node1.x > middle_x then true
        when get_char(node1.x, node1.y + 1)==TELEPORTER_CHAR && node1.y < middle_y then true
        when get_char(node1.x, node1.y - 1)==TELEPORTER_CHAR && node1.y > middle_y then true
        else false
        end
      node2_inner =
        case
        when get_char(node2.x + 1, node2.y)==TELEPORTER_CHAR && node2.x < middle_x then true
        when get_char(node2.x - 1, node2.y)==TELEPORTER_CHAR && node2.x > middle_x then true
        when get_char(node2.x, node2.y + 1)==TELEPORTER_CHAR && node2.y < middle_y then true
        when get_char(node2.x, node2.y - 1)==TELEPORTER_CHAR && node2.y > middle_y then true
        else false
        end
      
      case
      when node1_inner && !node2_inner
        node1.level == node2.level - 1
      when !node1_inner && node2_inner
        node1.level == node2.level + 1
      else
        false
      end
    end
  end
  
  # Dijkstra's algorithm.
  # expects a block with a PathNode arg to identify the target.
  # NOTE that the resulting path includes the start node.
  def find_path(x : Int16, y : Int16, consider_unexplored = false, level = 0_i8,
                heuristic_checker : Proc(PathNode, Bool)|Nil = nil )
    visited = Array(PathNode).new
    unvisited = Array(PathNode).new

    levels_added = Array(Int8).new
    add_level = ->(lvl : Int8) {
      return if lvl > 30 # day 20 part 2 takes a long time without this
      return false if levels_added.includes?(lvl)
      all_y.min.to(all_y.max) do |y|
        all_x.min.to(all_x.max) do |x|
          unvisited << PathNode.new(x, y, lvl) unless get(x,y).nil?
        end
      end
      unvisited.sort_by! do |n|
        [level.-(n.level).abs, x.-(n.x).abs, y.-(n.y).abs]
      end
      levels_added << lvl
      true
    }
    add_level.call(level)
    if teleport_mode == :levels
      add_level.call(level + 1)
    end

    # allows path to traverse undefined map tiles.
    if consider_unexplored
      unexplored = Array(PathNode).new
      unvisited.each do |node|
        [[1,0],[-1,0],[0,1],[0,-1]].each do |pair|
          neighbor = PathNode.new(node.x + pair[0], node.y + pair[1]) 
          unless unvisited.includes?(neighbor)
            unexplored << neighbor
          end
        end
      end
      unvisited += unexplored
      unvisited.uniq!
    end

    current = unvisited.find do |n|
      n.x==x && n.y==y && n.level == level
    end
    return unless current
    current.distance = 0

    found = false
    until found # main loop
      # get neighbors of current node, and update their distances if
      # the path through the current node is shorter than their existing distance.
      neighbors = unvisited.select do |n|
        next false if n == current
        n.neighbor_of?(current) || teleport_between?(current, n)
      end
      neighbors.each do |neighbor|
        tile = get(neighbor.x, neighbor.y)
        if distance(tile) != UNREACHABLE
          if current.distance + distance(tile) < neighbor.distance
            neighbor.distance = current.distance + distance(tile)
            neighbor.parent = current
          end
        end
      end

      # mark current node as visited
      current.visited = true
      unvisited.delete(current)
      visited << current

      # pick a new current node
      return if unvisited.size == 0
      unvisited.sort_by!{|n|n.distance}

      closest = 
        if heuristic_checker.nil?
          unvisited.first
        else
          unvisited.find { |node| heuristic_checker.call(node) }
        end

      return if closest.nil? || closest.distance == UNREACHABLE
      current = closest
      if teleport_mode == :levels
        unless levels_added.includes?(current.level + 1)
          add_level.call(current.level + 1)
        end
      end

      # yield if block indicates that we found target
      found = true if yield(current)
    end # main loop

    # return path from current node back to starting node
    path = Array(PathNode).new
    parent = current
    while !parent.nil?
      path << parent
      parent = parent.parent
    end
    path.reverse
  end

  def all_y; @map.keys; end
  def all_x; @map.values.flatten.map(&.keys).flatten; end

  # TODO remove my x/y/char. just a hacky way to show where the droid is.
  # instead implement as another map layer of objects/actors.
  def draw(my_x : Int16 = -1, my_y : Int16 = -1, my_char = '@')
    `clear`
    puts "------------------"
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        if x == my_x && y == my_y
          print my_char
          next
        end
        if @map.has_key?(y) && @map[y].has_key?(x)
          tile = @map[y][x]
          print @tiles.has_key?(tile) ? @tiles[tile] : UNKNOWN_CHAR
          next
        end
        print ' '
      end
      puts
    end
    puts
    #sleep 0.05
  end

  def each_char
    each do |x, y, tile|
      next if tile.nil?
      yield x, y, @tiles[tile]
    end
  end

  def each
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        yield x, y, get(x, y)
      end
    end
  end

  def trim
    each_char do |x, y, char|
      unset(x, y) if char=='#'
    end
  end

  # assumes #trim has been run
  def fill_dead_ends(x : Int16, y : Int16)
    #map.draw(pos[:x], pos[:y], '@')
    #puts "#fill_dead_ends"
    fill_dead_ends_with_scan x, y
  end

  def fill_dead_ends_with_scan(x : Int16, y : Int16)
    filled = true
    while filled
      filled = false
      each_char do |x, y, char|
        floor = char == '.'
        next unless floor
        dead_end = neighbors(x, y).size == 1
        next unless dead_end
        teleporter = @teleporters.values.flatten.includes?({x: x, y: y})
        next unless !teleporter
        unset(x, y)
        filled = true
      end
    end
  end

  def fill_dead_ends_with_pathfinding(x : Int16, y : Int16)
    path = find_path(x, y) do |node|
      floor = get_char(node.x, node.y) == '.'
      next unless floor
      dead_end = neighbors(node.x, node.y).size == 1
      next unless dead_end
      teleporter = @teleporters.values.flatten.includes?({x: node.x, y: node.y})
      next unless !teleporter
      true
    end
    return if path.nil?
    path.shift # current position
    path.reverse.each do |node|
      floor = get_char(node.x, node.y) == '.'
      next unless floor
      dead_end = neighbors(node.x, node.y).size == 1
      next unless dead_end
      teleporter = @teleporters.values.flatten.includes?({x: node.x, y: node.y})
      next unless !teleporter
      unset(node.x, node.y)
    end
    fill_dead_ends_with_pathfinding x, y
  end

end

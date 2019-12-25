class Map

  UNREACHABLE = Int32::MAX

  def initialize(tiles : Array(Char))
    tiles_h = Hash(Int8, Char).new
    tiles.each.with_index do |tile, i|
      tiles_h[i.to_i8] = tile
    end
    initialize tiles_h
  end

  def initialize(@tiles : Hash(Int8, Char))
    @map = Hash(Int32, Hash(Int32, Int8)).new
    @distances = Hash(Int8, Int32).new
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
        set x, y, tile
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

  def neighbors(x : Int32, y : Int32)
    [
      {x: 0, y: -1},
      {x: 0, y: 1},
      {x: -1, y: 0},
      {x: 1, y: 0}
    ].map do |coords|
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

  def set(x : Int32, y : Int32, tile : Int8|Char|Nil)
    tile = @tiles.key_for(tile) if tile.is_a? Char
    return false if tile.nil?
    @map[y] = Hash(Int32, Int8).new if !@map.has_key?(y)
    @map[y][x] = tile
    true
  end

  def get(x : Int32, y : Int32)
    return nil if !@map.has_key?(y)
    return nil if !@map[y].has_key?(x)
    @map[y][x]
  end

  class PathNode
    property x, y
    property parent : (PathNode|Nil)
    property visited : Bool
    property distance : Int32
    def initialize(@x : Int32, @y : Int32)
      @visited = false
      @distance = UNREACHABLE
    end
    def neighbor_of?(node : PathNode)
      (@x-node.x).abs + (@y-node.y).abs < 2
    end
    def ==(other : PathNode)
      x==other.x && y==other.y
    end
  end
  
  # Dijkstra's algorithm.
  # expects a block with a PathNode arg to identify the target.
  # NOTE that the resulting path includes the start node.
  def find_path(x : Int32, y : Int32, consider_unexplored = false)
    visited = Array(PathNode).new
    unvisited = Array(PathNode).new
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        unvisited << PathNode.new(x,y) unless get(x,y).nil?
      end
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

    current = unvisited.find{|n|n.x==x && n.y==y}
    return unless current
    current.distance = 0

    found = false
    until found # main loop
      # get neighbors of current node, and update their distances if
      # the path through the current node is shorter than their existing distance.
      neighbors = unvisited.select { |node| node.neighbor_of?(current) && node!=current}
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
      closest = unvisited.first
      return if closest.distance == UNREACHABLE
      current = closest

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
  def draw(my_x : Int32 = -1, my_y : Int32 = -1, my_char = '@')
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
          print @tiles.has_key?(tile) ? @tiles[tile] : '?'
          next
        end
        print ' '
      end
      puts
    end
    puts
    sleep 0.05
  end

  def each
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        yield x, y, get(x, y)
      end
    end
  end
end

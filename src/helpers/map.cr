class Map

  #UNKNOWN = -1

  def initialize(@tiles : Hash(Int8, Char))
    @map = Hash(Int32, Hash(Int32, Int8)).new
  end

  def update(x : Int32, y : Int32, tile : Int8|Char|Nil)
    tile = @tiles.key_for(tile) if tile.is_a? Char
    return if tile.nil?
    @map[y] = Hash(Int32, Int8).new if !@map.has_key?(y)
    @map[y][x] = tile
  end

  # `map` is expected to be a multi-line string, e.g. a heredoc
  def import(map : String)
    map.split("\n").each.with_index do |line, y|
      line.chars.each.with_index do |tile, x|
        update x, y, tile
      end
    end
  end

  def at(x : Int32, y : Int32)
    return nil if !@map.has_key?(y)
    return nil if !@map[y].has_key?(x)
    @map[y][x]
  end

  class Node
    UNREACHABLE = 1_000_000_000
    property x, y
    property parent : (Node|Nil)
    property visited : Bool
    property distance : Int32
    def initialize(@x : Int32, @y : Int32)
      @visited = false
      @distance = UNREACHABLE
    end
    def parent=(node : Node)
      @parent = node
    end
    def neighbor_of?(node : Node)
      (@x-node.x).abs + (@y-node.y).abs < 2
    end
    def ==(other : Node)
      x==other.x && y==other.y
    end
  end

  def find_path(x : Int32, y : Int32)
    visited = Array(Node).new
    unvisited = Array(Node).new
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        unvisited << Node.new(x,y) unless at(x,y).nil?
      end
    end

    unexplored = Array(Node).new
    unvisited.each do |node|
      [[1,0],[-1,0],[0,1],[0,-1]].each do |pair|
        neighbor = Node.new(node.x + pair[0], node.y + pair[1]) 
        unless unvisited.includes?(neighbor)
          unexplored << neighbor
        end
      end
    end
    unvisited += unexplored 
    unvisited.uniq!

    current = unvisited.find{|n|n.x==x && n.y==y}
    return unless current
    current.distance = 0
    found = false
    until found
      neighbors = unvisited.select { |node| node.neighbor_of?(current) && node!=current}
      neighbors.each do |neighbor|
        tile = at(neighbor.x, neighbor.y)
        unless tile == 0 # wall
          if current.distance + 1 < neighbor.distance
            neighbor.distance = current.distance + 1
            neighbor.parent = current
          end
        end
      end
      current.visited = true
      unvisited.delete(current)
      visited << current
      return unless unvisited.size > 0
      unvisited.sort_by!{|n|n.distance}
      closest = unvisited.first
      return if closest.distance == Node::UNREACHABLE
      current = closest
      if yield(current)
        found = true
      end
    end
    path = Array(Node).new
    parent = current
    while !parent.nil?
      path << parent
      parent = parent.parent
    end
    path.reverse
  end

  def all_y
    @map.keys
  end

  def all_x
    @map.values.flatten.map{|h|h.keys}.flatten
  end

  # TODO remove my x/y. just a hacky way to show where the droid is. implement as another map layer of objects/actors.
  def draw(my_x : Int32, my_y : Int32)
    `clear`
    #puts "------------------"
    all_y.min.to(all_y.max) do |y|
      all_x.min.to(all_x.max) do |x|
        if x == my_x && y == my_y
          print 'D'
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
    sleep 0
  end
end

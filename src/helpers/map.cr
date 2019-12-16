class Map

  #UNKNOWN = -1

  def initialize(@tiles : Hash(Int8, Char))
    @map = Hash(Int32, Hash(Int32, Int8)).new
  end

  def update(x : Int32, y : Int32, tile : Int8)
    @map[y] = Hash(Int32, Int8).new if !@map.has_key?(y)
    @map[y][x] = tile
  end

  def at(x : Int32, y : Int32)
    return nil if !@map.has_key?(y)
    return nil if !@map[y].has_key?(x)
    @map[y][x]
  end

  # TODO remove my x/y. just a hacky way to show where the droid is. implement as another map layer of objects/actors.
  def draw(my_x : Int32, my_y : Int32)
    `clear`
    puts "------------------"
    all_y = @map.keys
    all_x = @map.values.flatten.map{|h|h.keys}.flatten
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
    sleep 0.5
  end

  #private def fill
  #  all_y = @map.keys
  #  all_x = @map.values.flatten.map{|h|h.keys}.flatten
  #  all_y.min.to(all_y.max) do |y|
  #    all_x.min.to(all_x.max) do |x|
  #      @map[y] = Hash(Int32, Int8).new if !@map.has_key?(y)
  #      @map[y][x] = Int8.new(UNKNOWN) if !@map[y].has_key?(x)
  #    end
  #  end
  #end
end

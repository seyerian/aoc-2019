class Aoc2019::Seventeen < Aoc2019::Solution
  def self.map_alignment_parameters_sum(map : Map)
    sum_of_alignment_params = 0
    map.each do |x, y, tile|
      next if tile.nil?
      next unless tile.chr == '#'
      neighbors = [map.get(x, y-1), map.get(x, y+1), map.get(x-1, y), map.get(x+1, y)]
      next unless neighbors.all? do |neighbor|
        next false if neighbor.nil?
        neighbor.chr == '#'
      end
      sum_of_alignment_params += x * y
    end
    sum_of_alignment_params
  end

  def self.part1_test_alignment
    map_drawn = <<-MAP_DRAWN
    ..#..........
    ..#..........
    #######...###
    #.#...#...#.#
    #############
    ..#...#...#..
    ..#####...^..
    MAP_DRAWN
    map = Map.new({
      '.'.ord.to_i8 => '.',
      '#'.ord.to_i8 => '#',
      '^'.ord.to_i8 => '^' 
    })
    map.import map_drawn
    map_alignment_parameters_sum map
  end

  def self.part1
    computer = IntcodeComputer.new File.read("inputs/17")
    outputs = Array(Int64).new
    computer.output = ->(ic : IntcodeComputer, o : Int64) {
      outputs << o
      true
    }
    computer.run
    tiles = Hash(Int8, Char).new
    outputs.uniq.each do |ascii|
      next if ascii.chr == '\n'
      tiles[ascii.to_i8] = ascii.chr
    end
    map = Map.new(tiles)
    x = y = 0
    outputs.each do |ascii|
      char = ascii.chr
      if char == '\n'
        x = 0
        y += 1
        next
      end
      map.set(x, y, char)
      x += 1
    end
    #map.draw
    map_alignment_parameters_sum map
  end

  def self.part2
    computer = IntcodeComputer.new File.read("inputs/17")
    outputs = Array(Int64).new
    computer.output = ->(ic : IntcodeComputer, o : Int64) {
      outputs << o
      true
    }
    computer.run
    tiles = Hash(Int8, Char).new
    outputs.uniq.each do |ascii|
      next if ascii.chr == '\n'
      tiles[ascii.to_i8] = ascii.chr
    end
    map = Map.new(tiles)
    x = y = 0
    outputs.each do |ascii|
      char = ascii.chr
      if char == '\n'
        x = 0
        y += 1
        next
      end
      map.set(x, y, char)
      x += 1
    end
    pos = map.find('^')
    scaffold_count = map.count('#')
    visited = Array(NamedTuple(x: Int32, y: Int32)).new
    moves = Array(Char).new
    last_offset = {x: 0, y: 0}
    until visited.size == scaffold_count
      old_pos = pos
      neighbors = map.neighbors(pos[:x], pos[:y])
      scaffolds = neighbors.select{|n|n[:char]=='#'}.map{|n|{x: n[:x], y: n[:y]}}
      case scaffolds.size
      when 1 # start or end
        if visited.includes?({x: scaffolds[0][:x], y: scaffolds[0][:y]})
          # `until` should have broken
        else
          pos = {x: scaffolds[0][:x], y: scaffolds[0][:y]}
          last_offset = {x: pos[:x] - old_pos[:x], y: pos[:y] - old_pos[:y]}
          visited << pos
        end
      when 2 # straight or turn
        # go to unvisited
        if unvisited = scaffolds.find{|s| !visited.includes?(s)}
          pos = {x: unvisited[:x], y: unvisited[:y]}
          last_offset = {x: pos[:x] - old_pos[:x], y: pos[:y] - old_pos[:y]}
          visited << pos
        else
          # moving into intersection already crossed
          pos = {x: pos[:x] + last_offset[:x], y: pos[:y] + last_offset[:y]}
        end
      when 4 # intersection
        # continue straight
        pos = {x: pos[:x] + last_offset[:x], y: pos[:y] + last_offset[:y]}
        visited << pos
      end

      move =
        case {x: pos[:x] - old_pos[:x], y: pos[:y] - old_pos[:y]}
        when {x: 0, y: -1} then 'N'
        when {x: 0, y: 1} then 'S'
        when {x: -1, y: 0} then 'W'
        when {x: 1, y: 0} then 'E'
        end

      offset = {x: pos[:x] - old_pos[:x], y: pos[:y] - old_pos[:y]}

      moves << move if !move.nil?
    end
    moves = moves.reduce(Array(Char).new) do |moves, move|
      case
      when moves.empty?
        moves << move
      when move.downcase == moves.last.downcase
        moves << move.downcase
      else
        moves << move
      end
      moves
    end
    last_dir = 'N'
    moves = moves.reduce(Array(Char).new) do |moves, move|
      case move
      when 'N', 'S', 'W', 'E'
        turn =
          case last_dir
          when 'N'
            move == 'W' ? 'L' : 'R'
          when 'S'
            move == 'W' ? 'R' : 'L'
          when 'W'
            move == 'N' ? 'R' : 'L'
          when 'E'
            move == 'N' ? 'L' : 'R'
          else '?'
          end
        moves << turn
        moves << 'f'
        last_dir = move
      when 'n', 's', 'w', 'e'
        moves << 'f'
      end
      moves
    end

    moves = moves.join
    30.to(1) do |i|
      moves = moves.gsub("f"*i,i)
    end

    # create movement functions
    mf_a = "L4L6L8L12"
    mf_b = "L8R12L12"
    mf_c = "R12L6L6L8"
    moves = moves.gsub(mf_a, "A")
    moves = moves.gsub(mf_b, "B")
    moves = moves.gsub(mf_c, "C")

    inputs = Array(Int64).new
    [moves, mf_a, mf_b, mf_c].each do |function|
      function.chars.each.with_index do |char, i|
        inputs << char.ord.to_i64
        if i < function.chars.size - 1
          # unless this char and next char are digits
          unless function.chars.size >= i && (char.ord >= 49 && char.ord <= 57) &&
              (function.chars[i+1].ord >= 49 && function.chars[i+1].ord <= 57)
            inputs << ','.ord.to_i64
          end
        else
          inputs << '\n'.ord.to_i64
        end
      end
    end

    # no video feed
    inputs << 'n'.ord.to_i64
    inputs << '\n'.ord.to_i64

    computer = IntcodeComputer.new File.read("inputs/17")
    computer.memory[0] = 2
    computer.input = ->(ic : IntcodeComputer) { inputs.shift }
    computer.run
    computer.outputs.last
  end
end

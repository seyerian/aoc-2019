class Aoc2019::Ten < Aoc2019::Solution
  alias Coords = NamedTuple(x: Int32, y: Int32)

  # RInfo contains:
  # - a line slope in decimal form
  # - x direction as +/- 1
  # - y direction as +/- 1
  # In a LineOfSight, this means the line connecting the related point to every point in Coords,
  # and the x and y direction of those points relative to the related point. Right=positive, down=positive.
  alias RInfo = Tuple(Float64, Int8, Int8)
  alias LineOfSight = Hash( RInfo, Array(Coords) )
  alias LinesOfSight = Hash( Coords, LineOfSight )

  def self.vaporize( sights : LinesOfSight, laser : Coords, stop : Int32 )

    vaporized = [] of Coords

    laser_sights = sights[laser]

    # get all the r_infos to be cycled through as angles.
    r_infos = laser_sights.map{ |r_info, asteroids|
      r_info
    }.sort_by do |r_info|
      slope, xdir, ydir = r_info
      # for points straight up or straight down, consider them to be on the right-hand side.
      # this ensures that points straight up are vaporized first, rather than last.
      xdir = 1 if xdir == 0
      # sort such that the first element is straight up, and following elements are ordered counterclockwise:
      # 1) all positive x values
      # 2) positive y values on the right-hand, negative x values on the left-hand
      # 3) slope
      [xdir * -1, ydir * xdir, slope]
    end

    r_infos.cycle do |r_info|
      break if vaporized.size == stop
      if asteroid = laser_sights[r_info].shift
        vaporized << asteroid
      end
    end

    vaporized
  end

  def self.lines_of_sight(rows : Array(String))
    asteroids = [] of Coords

    rows.each.with_index do |row, y|
      row.chars.each.with_index do |cell, x|
        next unless cell == '#'
        asteroids << {x: x, y: y}
      end
    end

    sights = LinesOfSight.new
    asteroids.each do |a|
      sights[a] = LineOfSight.new
    end

    sights.each do |a1, h|
      asteroids.each do |a2|
        next if a2==a1
        # distance between two points
        dx = a2[:x] - a1[:x]
        dy = a2[:y] - a1[:y]
        slope = (dy.to_f/dx).round(10)
        xdir = (dx/dx.abs).to_i8 # relative direction as +/- 1
        ydir = (dy/dy.abs).to_i8 # relative direction as +/- 1
        r_info = {slope, xdir, ydir}
        if !h.has_key? r_info
          h[r_info] = [a2]
        else
          h[r_info] << a2
          # sort all asteroids in this line of sight by distance from the astroid we are calculating LoS for 
          h[r_info].sort_by! do |coords|
            dx2 = a1[:x] - coords[:x]
            dy2 = a1[:y] - coords[:y]
            [dx2.abs, dy2.abs]
          end
        end
      end
    end

    sights
  end

  def self.find_station(sights : LinesOfSight)
    sights.max_by { |a,h| h.keys.size }
  end

  def self.display(sights : LinesOfSight, asteroid : Coords, rows : Array(String))
    a_sights = sights[asteroid]
    height = rows.size
    width = rows.first.chars.size
    height.times.with_index do |y|
      width.times.with_index do |x|
        if asteroid == {x: x, y: y}
          print '@'
        elsif a_sights.values.any?{|values|values.first == {x: x, y: y}}
          print '!'
        elsif sights.keys.includes?({x: x, y: y})
          print '#'
        else
          print '.'
        end
      end
      puts
    end
  end

  def self.part1
    station = find_station lines_of_sight(File.read_lines("inputs/10"))
    [station[0], station[1].size]
    #display File.read_lines("inputs/10"), station[0]
  end

  def self.part1_mini
    #display File.read_lines("inputs/test/10mini"), {x: 3, y: 4}
    station = find_station lines_of_sight(File.read_lines("inputs/test/10mini"))
    [station[0], station[1].size]
  end

  def self.part1_test1
    #display File.read_lines("inputs/test/10a"), {x: 5, y: 8}
    station = find_station lines_of_sight(File.read_lines("inputs/test/10a"))
    [station[0], station[1].size]
  end

  def self.part1_test2
    station = find_station lines_of_sight(File.read_lines("inputs/test/10b"))
    [station[0], station[1].size]
  end

  def self.part1_test3
    station = find_station lines_of_sight(File.read_lines("inputs/test/10c"))
    [station[0], station[1].size]
  end

  def self.part1_test4
    station = find_station lines_of_sight(File.read_lines("inputs/test/10d"))
    [station[0], station[1].size]
  end

  def self.part2
    rows = File.read_lines("inputs/10")
    sights = lines_of_sight rows
    station_location = find_station(sights)[0]
    #display sights, station_location, rows
    vaporized = vaporize sights, station_location, 200
    last = vaporized[199]
    last[:x] * 100 + last[:y]
  end

  def self.part2_test1
    rows = File.read_lines("inputs/test/10d")
    sights = lines_of_sight rows
    station_location = find_station(sights)[0]
    #display sights, station_location, rows
    vaporized = vaporize sights, station_location, 200
    last = vaporized[199]
    last[:x] * 100 + last[:y]
  end

end

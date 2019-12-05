# TODO cleanup
class Aoc2019::Three < Aoc2019::Solution

  def old_solution
    paths = File.read_lines("inputs/03")

    # parse codes and transform to line segments
    path_lines = paths.map do |path|
      lines = [] of Array(NamedTuple(x: Int32, y: Int32))
      path.split(',').reduce({x: 0,y: 0}) do |c, vector|
        dir = vector[0]
        len = vector[1..-1].to_i
        c2 =
          case dir
          when 'U' then {x: c[:x], y: c[:y]+len}
          when 'D' then {x: c[:x], y: c[:y]-len}
          when 'R' then {x: c[:x]+len, y: c[:y]}
          else          {x: c[:x]-len, y: c[:y]}
          end
        lines << [c, c2]
        c2
      end
      lines
    end

    # build list of intersections between line1 and line2
    intersections = [] of NamedTuple(x: Int32, y: Int32)
    path_lines[0].each do |j|
      path_lines[1].each do |k|
        # skip if x or y values don't collide
        next if [ j[0][:x], j[1][:x] ].max < [ k[0][:x], k[1][:x] ].min
        next if [ j[0][:x], j[1][:x] ].min > [ k[0][:x], k[1][:x] ].max
        next if [ j[0][:y], j[1][:y] ].max < [ k[0][:y], k[1][:y] ].min
        next if [ j[0][:y], j[1][:y] ].min > [ k[0][:y], k[1][:y] ].max

        # find exactly where the line segments collide
        j[0][:x].to(j[1][:x]) do |jx|
          j[0][:y].to(j[1][:y]) do |jy|
            k[0][:x].to(k[1][:x]) do |kx|
              k[0][:y].to(k[1][:y]) do |ky|
                if jx==kx && jy==ky
                  intersections << {x: jx, y: jy} 
                end
              end
            end
          end
        end
      end
    end

    closest_dist =
      intersections.uniq.map { |t|
        t[:x].abs + t[:y].abs
      }.reject { |t|
        t.zero?
      }.min

    ## PART 2

    shortest_steps = nil
    intersections.uniq.each do |intersection|
      next if intersection[:x] == 0 && intersection[:y] == 0

      path_steps = [0, 0]
      path_lines.each.with_index do |path_line, i|
        reached = false
        path_line.map{|l|l[1]}.reduce({x: 0, y: 0}) do |p, c|
          path_steps[i] -= 1 unless reached # a segment lenth of 5 is 4 steps, so -1 every segment
          p[:x].to(c[:x]) do |x|
            p[:y].to(c[:y]) do |y|
              next if reached
              path_steps[i] += 1
              reached = true if intersection[:x]==x && intersection[:y]==y
            end
          end
          c
        end
      end

      steps = path_steps.sum
      if shortest_steps.nil? || steps < shortest_steps
        shortest_steps = steps
      end
    end

    [closest_dist, shortest_steps]
  end

  def self.part1
    puts self.new.old_solution[0]
  end

  def self.part2
    puts self.new.old_solution[1]
  end
end

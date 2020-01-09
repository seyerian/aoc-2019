class Aoc2019::TwentyFour < Aoc2019::Solution
  class BugScan
    def initialize(starting_scan : String)
      @map = Map.new ['.', '#']
      @map.import starting_scan
      @ratings = [] of Int32
    end

    def step
      new_chars = Array(Tuple(Int16, Int16, Char)).new
      @map.each_char do |x, y, char|
        bug_count = @map.neighbors(x,y).count{|n|n[:char]=='#'}
        new_char =
          case char
          when '#'
            bug_count == 1 ? '#' : '.'
          else # '.'
            [1,2].includes?(bug_count) ? '#' : '.'
          end
        new_chars << {x, y, new_char}
      end
      rating = 0
      new_chars.each.with_index do |new_char, i|
        rating += 2 ** i if new_char[2] == '#'
        @map.set new_char[0], new_char[1], new_char[2]
      end
      @ratings << rating
    end

    def first_dup_rating
      #@map.draw
      loop do
        step
        #@map.draw
        return @ratings.last if @ratings.count(@ratings.last) == 2
      end
    end
  end

  def self.part1
    scan = BugScan.new File.read("inputs/24")
    scan.first_dup_rating
  end
end

class Aoc2019::Eighteen < Aoc2019::Solution

  class KeySolver
    def initialize(map_string : String)
      chars = Array(Char).new
      chars.concat ['#','.','@']
      chars.concat ('a'..'z').to_a
      chars.concat ('A'..'Z').to_a
      @map = Map.new chars
      @map.import map_string
    end

    def keys
      ('a'..'z').select do |key|
        !@map.find(key).nil?
      end
    end

    def steps
      0
    end
  end

end

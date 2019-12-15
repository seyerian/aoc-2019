def log(*args)
  return
  puts *args
end

class Aoc2019::Fourteen < Aoc2019::Solution
  class Nanofactory
    private getter reactions
    getter ore_used : Int64
    private setter ore_used
    getter ore_limit : Int64|Nil
    def initialize(reactions : Array(String), @ore_limit : (Int64|Nil) = nil)
      @ore_used = Int64.new(0)
      @noted_ore = Int64.new(0)
      @reactions = Hash(String, Reaction).new
      reactions.each do |reaction|
        inputs, output = reaction.split("=>").map{|s|s.strip}
        output_num, output_type = output.split(" ")
        inputs_h = Hash(String, Int32).new
        inputs.split(",").map{|s|s.strip}.each do |s|
          input_num, input_type = s.split(" ")
          inputs_h[input_type] = input_num.to_i32
        end
        @reactions[output_type] = Reaction.new(self, output_type, output_num.to_i32, inputs_h)
      end
    end

    def produce(type : String, num : (Int32|Nil) = nil)
      self.ore_used = Int64.new(0)

      return unless reaction = reaction_for type

      unless num.nil?
        return reaction.get num
      end

      produced = 0
      batch = 10_000
      while batch > 0
        note_ore
        @reactions.values.each do |reaction|
          reaction.note_leftovers
        end
        if batch == reaction.get(batch)
          produced += batch
        else
          return_ore
          @reactions.values.each do |reaction|
            reaction.return_leftovers
          end
          # try a smaller batch size
          batch = batch == 1 ? 0 : (batch / 2).to_i32
        end
      end
      produced
    end

    def note_ore
      @noted_ore = @ore_used
    end

    def return_ore
      @ore_used = @noted_ore
    end

    def get_ore(need : Int32)
      puts ore_used
      #log "--- need #{need} ore"
      limit = @ore_limit
      would_use = ore_used + need
      if limit.nil?
        #log "--- no limit."
        self.ore_used = would_use
        return need
      end

      if would_use > limit
        # this would use more than limit, return as much as we have
        #log "--- all left is #{would_use - limit}"
        return would_use - limit
      end

      self.ore_used += need.to_i64
      #self.ore_used = would_use
      #log "--- used #{need}"
      need
    end

    def reaction_for(output_type : String)
      #@reactions.find{|r| r.output_type==output_type}
      @reactions[output_type]
    end
  end

  class Nanofactory::Reaction
    getter output_type, output_num, inputs
    def initialize(@factory : Nanofactory, @output_type : String, @output_num : Int32, @inputs : Hash(String, Int32))
      @leftovers = 0
      @noted_leftovers = 0
    end

    def note_leftovers
      @noted_leftovers = @leftovers
    end

    def return_leftovers
      @leftovers = @noted_leftovers
    end

    def get(need : Int32)
      #log "need #{need} #{output_type} (#{@leftovers} leftovers)"

      remaining_need = need
      if (leftovers = @leftovers) > 0
        leftovers_used = [remaining_need, leftovers].min
        remaining_need -= leftovers_used
        @leftovers -= leftovers_used
        #log "- used #{leftovers_used} leftovers"
      end

      return need if remaining_need == 0

      # scale reaction until output produced satisfies remaining_need
      scale = 1
      while remaining_need > scale * output_num
        scale += 1
      end
      #log "- scale #{scale}"

      # go get inputs
      shuffled = @inputs.to_a.sample(@inputs.keys.size).to_h
      shuffled.each do |input_type, input_num|
        input_needed = input_num * scale
        if input_type == "ORE"
          unless @factory.get_ore(input_needed) == input_needed
            return 0
          end
        elsif reaction = @factory.reaction_for input_type
          unless reaction.get(input_needed) == input_needed
            return 0
          end
        else
          return 0
        end
      end

      #left_over = (scale * output_num) - remaining_need
      #if left_over > 0
      #log "- #{left_over} left over"
      #end
      #@leftovers += left_over
      @leftovers += (scale * output_num) - remaining_need

      need
    end
  end

  def self.part1
    fact = Nanofactory.new File.read_lines("inputs/14")
    fact.produce "FUEL", 1
    fact.ore_used
  end

  def self.part1_small
    fact = Nanofactory.new File.read_lines("inputs/test/14small")
    fact.produce "FUEL", 1
    fact.ore_used
  end

  def self.part1_test1
    fact = Nanofactory.new File.read_lines("inputs/test/14a")
    fact.produce "FUEL", 1
    fact.ore_used
  end

  def self.part1_test2
    fact = Nanofactory.new File.read_lines("inputs/test/14b")
    fact.produce "FUEL", 1
    fact.ore_used
  end

  def self.part1_test3
    fact = Nanofactory.new File.read_lines("inputs/test/14c")
    fact.produce "FUEL", 1
    fact.ore_used
  end

  def self.part1_test_z
    fact = Nanofactory.new File.read_lines("inputs/test/14z")
    fact.produce "FUEL", 1
    fact.ore_used
  end

  def self.part1_test_y
    fact = Nanofactory.new File.read_lines("inputs/test/14y")
    fact.produce "FUEL", 1
    fact.ore_used
  end

  def self.part2
    fact = Nanofactory.new File.read_lines("inputs/14"), 1_000_000_000_000
    fact.produce "FUEL"
  end

  def self.part2_test1
    fact = Nanofactory.new File.read_lines("inputs/test/14a"), 1_000_000_000_000
    fact.produce "FUEL"
  end

  def self.part2_test2
    fact = Nanofactory.new File.read_lines("inputs/test/14b"), 1_000_000_000_000
    fact.produce "FUEL"
  end

  def self.part2_test3
    fact = Nanofactory.new File.read_lines("inputs/test/14c"), 1_000_000_000_000
    fact.produce "FUEL"
  end
end

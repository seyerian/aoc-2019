class Aoc2019::Four < Aoc2019::Solution
  MIN=307237
  MAX=769058

  def self.valid?(n : Int32, respect_bounds = true, larger_matching_groups = true)
    s = n.to_s
    return false if (n < MIN && respect_bounds)
    return false if (n > MAX && respect_bounds)
    return false unless s.size == 6
    return false unless /(\d)\1/.match(s)

    if !larger_matching_groups
      len2 = false
      s.scan(/(\d)(\1{1,})/) do |match|
        len2 = true if $2.size==1
      end
      return false if !len2
    end

    last = -1
    s.chars.each do |c|
      i = c.to_i
      return false unless i >= last
      last = i
    end
    true
  end

  def self.part1
    num_valid = 0
    MIN.to(MAX) do |n|
      num_valid += 1 if valid?(n)
    end
    puts num_valid
  end

  def self.part2
    num_valid = 0
    MIN.to(MAX) do |n|
      num_valid += 1 if valid?(n, larger_matching_groups: false)
    end
    puts num_valid
  end

end

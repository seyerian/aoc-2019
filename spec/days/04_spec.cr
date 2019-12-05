require "../spec_helper"

describe Aoc2019::Four do
  describe "::valid?" do
    it "satisfies test values" do
      Aoc2019::Four.valid?(111111, respect_bounds: false).should be_true
      Aoc2019::Four.valid?(223450, respect_bounds: false).should be_false
      Aoc2019::Four.valid?(123789, respect_bounds: false).should be_false
    end
    it "satisfies part 2 test values" do
      Aoc2019::Four.valid?( 112233, respect_bounds: false, larger_matching_groups: false ).should be_true
      Aoc2019::Four.valid?( 123444, respect_bounds: false, larger_matching_groups: false ).should be_false
      Aoc2019::Four.valid?( 111122, respect_bounds: false, larger_matching_groups: false ).should be_true
    end
    it "returns true when there is a large matching group but also a group of two" do
      Aoc2019::Four.valid?( 224444, respect_bounds: false, larger_matching_groups: false ).should be_true
      Aoc2019::Four.valid?( 224555, respect_bounds: false, larger_matching_groups: false ).should be_true
      Aoc2019::Four.valid?( 225666, respect_bounds: false, larger_matching_groups: false ).should be_true
      Aoc2019::Four.valid?( 226666, respect_bounds: false, larger_matching_groups: false ).should be_true
    end
    it "returns false for larger matching groups" do
      Aoc2019::Four.valid?( 444444, respect_bounds: false, larger_matching_groups: false ).should be_false
      Aoc2019::Four.valid?( 444555, respect_bounds: false, larger_matching_groups: false ).should be_false
      Aoc2019::Four.valid?( 555666, respect_bounds: false, larger_matching_groups: false ).should be_false
      Aoc2019::Four.valid?( 555666, respect_bounds: false, larger_matching_groups: false ).should be_false
    end
  end
end

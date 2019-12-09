require "../spec_helper"

describe Aoc2019::Nine do
  describe "::part1" do
    it "equals 3460311188" do
      Aoc2019::Nine.part1.should eq 3460311188
    end
  end
  describe "::part1_test1" do
    it "equals self" do
      Aoc2019::Nine.part1_test1.should eq [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    end
  end
  describe "::part1_test2" do
    it "equals nil" do
      Aoc2019::Nine.part1_test2.to_s.size.should eq 16
    end
  end
  describe "::part1_test3" do
    it "equals 1125899906842624" do
      Aoc2019::Nine.part1_test3.should eq 1125899906842624
    end
  end
  describe "::part2" do
    it "equals 42202" do
      Aoc2019::Nine.part2.should eq 42202
    end
  end
end

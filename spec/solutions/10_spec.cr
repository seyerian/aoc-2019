require "../spec_helper"

describe Aoc2019::Ten do
  describe "::part1" do
    it "equals 20,18/280" do
      Aoc2019::Ten.part1.should eq [{x: 20, y: 18}, 280]
    end
  end
  describe "::part1_test1" do
    it "equals 5,8/33" do
      Aoc2019::Ten.part1_test1.should eq [{x: 5, y: 8}, 33]
    end
  end
  describe "::part1_test2" do
    it "equals 1,2/35" do
      Aoc2019::Ten.part1_test2.should eq [{x: 1, y: 2}, 35]
    end
  end
  describe "::part1_test3" do
    it "equals 6,3/41" do
      Aoc2019::Ten.part1_test3.should eq [{x: 6, y: 3}, 41]
    end
  end
  describe "::part1_test4" do
    it "equals 11,13/210" do
      Aoc2019::Ten.part1_test4.should eq [{x: 11, y: 13}, 210]
    end
  end
  describe "::part2" do
    it "equals 706" do
      Aoc2019::Ten.part2.should eq 706
    end
  end
  describe "::part2_test1" do
    it "equals 802" do
      Aoc2019::Ten.part2_test1.should eq 802
    end
  end
end

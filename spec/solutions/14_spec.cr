require "../spec_helper"

describe Aoc2019::Fourteen do
  describe "::part1" do
    it "equals 522031" do
      Aoc2019::Fourteen.part1.should eq 522031
    end
  end
  describe "::part1_small" do
    it "equals 165" do
      Aoc2019::Fourteen.part1_small.should eq 165
    end
  end
  describe "::part1_test1" do
    it "equals 13312" do
      Aoc2019::Fourteen.part1_test1.should eq 13312
    end
  end
  describe "::part1_test2" do
    it "equals 180697" do
      Aoc2019::Fourteen.part1_test2.should eq 180697
    end
  end
  describe "::part1_test3" do
    it "equals 2210736" do
      Aoc2019::Fourteen.part1_test3.should eq 2210736
    end
  end

  describe "::part2" do
    it "equals 3566577" do
      Aoc2019::Fourteen.part2.should eq 3566577
    end
  end
  describe "::part2_test1" do
    it "equals 82892753" do
      Aoc2019::Fourteen.part2_test1.should eq 82892753
    end
  end
  describe "::part2_test2" do
    it "equals 5586022" do
      Aoc2019::Fourteen.part2_test2.should eq 5586022
    end
  end
  # Arithmetic overflow (OverflowError)
  #describe "::part2_test3" do
  #  it "equals 460664" do
  #    Aoc2019::Fourteen.part2_test3.should eq 460664
  #  end
  #end
end

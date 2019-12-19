require "../spec_helper"

describe Aoc2019::Sixteen do
  describe "::fft_pattern_value" do
    it "returns the correct pattern value for the given scale and index" do
      # scale 1
      Aoc2019::Sixteen.fft_pattern_value(1, 1).should eq 1
      Aoc2019::Sixteen.fft_pattern_value(1, 2).should eq 0
      Aoc2019::Sixteen.fft_pattern_value(1, 3).should eq -1
      Aoc2019::Sixteen.fft_pattern_value(1, 4).should eq 0
      Aoc2019::Sixteen.fft_pattern_value(1, 5).should eq 1
      # scale 2
      values = [1,2,3,4,5,6,7,8,9,10].map do |n|
        Aoc2019::Sixteen.fft_pattern_value(2, n)
      end
      values.should eq [0,1,1,0,0,-1,-1,0,0,1]
      values = [1,2,3,4,5,6,7,8,9,10].map do |n|
        Aoc2019::Sixteen.fft_pattern_value(3, n)
      end
      values.should eq [0,0,1,1,1,0,0,0,-1,-1]
    end
  end
  describe "::part1_test1" do
    it "equals 01029498" do
      Aoc2019::Sixteen.part1_test1.should eq "01029498"
    end
  end
  describe "::part1_test2" do
    it "equals 24176176" do
      Aoc2019::Sixteen.part1_test2.should eq "24176176"
    end
  end
  describe "::part1_test3" do
    it "equals 73745418" do
      Aoc2019::Sixteen.part1_test3.should eq "73745418"
    end
  end
  describe "::part1_test4" do
    it "equals 52432133" do
      Aoc2019::Sixteen.part1_test4.should eq "52432133"
    end
  end
  describe "::part1" do
    it "equals 90744714" do
      Aoc2019::Sixteen.part1.should eq "90744714"
    end
  end
end

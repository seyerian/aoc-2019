require "../spec_helper"

describe Aoc2019::TwentyFour do
  describe "part 1 test 1" do
    it "equals 2129920" do
      scan = Aoc2019::TwentyFour::BugScan.new File.read("inputs/test/24a")
      scan.first_dup_rating.should eq 2129920
    end
  end
  describe "part 1" do
    it "equals 18859569" do
      Aoc2019::TwentyFour.part1.should eq 18859569
    end
  end
end

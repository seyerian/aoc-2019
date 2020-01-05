require "../spec_helper"

describe Aoc2019::Twenty do
  describe "part 1" do
    it "equals 556" do
      Aoc2019::Twenty.find_min_path(File.read("inputs/20")).should eq 556
    end
  end
  describe "part 1 test 1" do
    it "equals 23" do
      Aoc2019::Twenty.find_min_path(File.read("inputs/test/20a")).should eq 23
    end
  end
  describe "part 1 test 2" do
    it "equals 58" do
      Aoc2019::Twenty.find_min_path(File.read("inputs/test/20b")).should eq 58
    end
  end
  #describe "part 2" do
  #  it "equals 6532" do
  #    Aoc2019::Twenty.find_min_path(File.read("inputs/20"), :levels).should eq 6536
  #  end
  #end
  describe "part 2 test" do
    it "equals 396" do
      Aoc2019::Twenty.find_min_path(File.read("inputs/test/20-2a"), :levels).should eq 396
    end
  end
end

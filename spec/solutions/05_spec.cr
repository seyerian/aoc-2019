require "../spec_helper"

describe Aoc2019::Five do
  describe "::part1" do
    it "equals 9431221" do
      Aoc2019::Five.part1.should eq 9431221
    end
  end

  describe "::part2" do
    it "equals 1409363" do
      Aoc2019::Five.part2.should eq 1409363
    end
  end

  describe "::part2_test_compare" do
    describe "program one" do
      it "outputs 1 if the input is equal to 8" do
        Aoc2019::Five.part2_test_compare("one", 8).should eq 1
      end
      it "outputs 0 if the input is not equal to 8" do
        Aoc2019::Five.part2_test_compare("one", 7).should eq 0
      end
    end
    describe "program two" do
      it "outputs 1 if the input is less than 8" do
        Aoc2019::Five.part2_test_compare("two", 7).should eq 1
      end
      it "outputs 0 if the input is not less than 8" do
        Aoc2019::Five.part2_test_compare("two", 9).should eq 0
      end
    end
    describe "program three" do
      it "outputs 1 if the input is equal to 8" do
        Aoc2019::Five.part2_test_compare("three", 8).should eq 1
      end
      it "outputs 0 if the input is not equal to 8" do
        Aoc2019::Five.part2_test_compare("three", 7).should eq 0
      end
    end
    describe "program four" do
      it "outputs 1 if the input is less than 8" do
        Aoc2019::Five.part2_test_compare("four", 7).should eq 1
      end
      it "outputs 0 if the input is not less than 8" do
        Aoc2019::Five.part2_test_compare("four", 9).should eq 0
      end
    end
  end
  describe "::part2_test_jump" do
    describe "program one" do
      it "outputs 0 if the input is zero" do
        Aoc2019::Five.part2_test_jump("one", 0).should eq 0
      end
      it "outputs 1 if the input is non-zero" do
        Aoc2019::Five.part2_test_jump("one", rand(10000000)+1).should eq 1
        Aoc2019::Five.part2_test_jump("one", -1*rand(10000000)+1).should eq 1
      end
    end
    describe "program two" do
      it "outputs 0 if the input is zero" do
        Aoc2019::Five.part2_test_jump("one", 0).should eq 0
      end
      it "outputs 1 if the input is non-zero" do
        Aoc2019::Five.part2_test_jump("one", rand(10000000)+1).should eq 1
        Aoc2019::Five.part2_test_jump("one", -1*rand(10000000)+1).should eq 1
      end
    end
  end
end

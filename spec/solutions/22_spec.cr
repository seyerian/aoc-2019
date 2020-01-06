require "../spec_helper"

describe Aoc2019::TwentyTwo do
  describe "part 1 test 1" do
    it "" do
      deck = Aoc2019::TwentyTwo::SpaceCardDeck.new 10
      deck.shuffle File.read("inputs/test/22a")
    end
  end
  describe "part 1 test 2" do
    it "" do
      deck = Aoc2019::TwentyTwo::SpaceCardDeck.new 10
      deck.shuffle File.read("inputs/test/22b"), 4
    end
  end
  describe "part 1" do
    it "equals 2604" do
      Aoc2019::TwentyTwo.part1.should eq 2604
    end
  end
  describe Aoc2019::TwentyTwo::MagicSpaceCardDeck do
    it "tells which card lands in a given position after shuffle" do
      deck = Aoc2019::TwentyTwo::MagicSpaceCardDeck.new 10007
      deck.reverse_shuffle_offset(File.read("inputs/22"), 2604).should eq 2019
    end
    it "test time" do
      deck = Aoc2019::TwentyTwo::MagicSpaceCardDeck.new 119315717514047
      deck.reverse_shuffle_offset File.read("inputs/22"), 2020
    end
  end
  #describe "part 2" do
  #  it "equals 1143351187" do
  #    Aoc2019::TwentyTwo.part2.should eq 1143351187
  #  end
  #end
end

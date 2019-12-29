require "../spec_helper"

describe Aoc2019::Eighteen do
  describe "test 1" do
    it "equals 8" do
      map = <<-MAP
      #########
      #b.A.@.a#
      #########
      MAP
      Aoc2019::Eighteen.solve(map).should eq 8
    end
  end
  describe "test 2" do
    it "equals 86" do
      map = <<-MAP
      ########################
      #f.D.E.e.C.b.A.@.a.B.c.#
      ######################.#
      #d.....................#
      ########################
      MAP
      Aoc2019::Eighteen.solve(map).should eq 86
    end
  end
  describe "test 3" do
    it "equals 132" do
      map = <<-MAP
      ########################
      #...............b.C.D.f#
      #.######################
      #.....@.a.B.c.d.A.e.F.g#
      ########################
      MAP
      Aoc2019::Eighteen.solve(map).should eq 132
    end
  end
  describe "test 4" do
    it "equals 136" do
      map = <<-MAP
      #################
      #i.G..c...e..H.p#
      ########.########
      #j.A..b...f..D.o#
      ########@########
      #k.E..a...g..B.n#
      ########.########
      #l.F..d...h..C.m#
      #################
      MAP
    end
  end
  describe "test 5" do
    it "equals 81" do
      map = <<-MAP
      ########################
      #@..............ac.GI.b#
      ###d#e#f################
      ###A#B#C################
      ###g#h#i################
      ########################
      MAP
    end
  end

  describe "test z1" do
    it "equals 41" do
      map = <<-MAP
      ###########
      #Bc.....bC#
      ###A#######
      #...#...#a#
      #.#.#.#.#.#
      #@#...#...#
      ###########
      MAP
      Aoc2019::Eighteen.solve(map).should eq 41
    end
  end
end

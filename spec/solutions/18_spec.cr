require "../spec_helper"

describe Aoc2019::Eighteen do
  describe "test 1" do
    it "equals 8" do
      map = <<-MAP
      #########
      #b.A.@.a#
      #########
      MAP
      ks = Aoc2019::Eighteen::KeySolver.new(map)
      ks.steps.should eq 8
    end
  end
  describe "test 2" do
    pending "equals 86" do
      map = <<-MAP
      ########################
      #f.D.E.e.C.b.A.@.a.B.c.#
      ######################.#
      #d.....................#
      ########################
      MAP
    end
  end
  describe "test 3" do
    pending "equals 132" do
      map = <<-MAP
      ########################
      #...............b.C.D.f#
      #.######################
      #.....@.a.B.c.d.A.e.F.g#
      ########################
      MAP
    end
  end
  describe "test 4" do
    pending "equals 136" do
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
    pending "equals 81" do
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
end

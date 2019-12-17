require "../spec_helper"

describe Map do
  describe "#find_path" do
    it "returns the shortest path between two points" do
      map = Map.new({Int8.new(0) => '#', Int8.new(1) => '.'})
      map.import(
      <<-MAP
      #######
      #.....#
      #####.#
      #.....#
      #.#####
      #.....#
      #######
      MAP
      )
      path = map.find_path(1,1) do |node|
        node.x==5 && node.y==5
      end
      path.should_not be nil
      path.size.should eq 17 if !path.nil?
    end
    it "returns the shortest path between two points" do
      map = Map.new({Int8.new(0) => '#', Int8.new(1) => '.'})
      map.import(
      <<-MAP
      #######
      #.....#
      #####.#
      #.....#
      #.###.#
      #...#.#
      #######
      MAP
      )
      path = map.find_path(1,1) do |node|
        node.x==5 && node.y==5
      end
      path.should_not be nil
      path.size.should eq 9 if !path.nil?
    end
  end
end

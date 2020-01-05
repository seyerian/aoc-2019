class Aoc2019::Twenty < Aoc2019::Solution
  def self.find_min_path(map_string : String, teleport_mode = :default)
    chars = ['#','.']
    chars.concat ('A'..'Z').to_a
    map = Map.new chars
    map.has_teleporters = true
    map.teleport_mode = teleport_mode
    ('A'..'Z').each do |char|
      map.teleporter_label_tiles << char
    end
    map.import map_string
    map.trim 
    #map.teleporters.values.flatten.each do |position|
    #end
    start = map.teleporters["AA"].first
    map.fill_dead_ends start[:x], start[:y]
    #map.draw
    finish = map.teleporters["ZZ"].first
    map.teleporters.delete "AA"
    map.teleporters.delete "ZZ"
    path = map.find_path start[:x], start[:y] do |node|
      node.x == finish[:x] && node.y == finish[:y] && node.level == 0_i8
    end
    return if path.nil?
    path.size - 1
  end
end

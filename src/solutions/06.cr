class Aoc2019::Six < Aoc2019::Solution

  class Orbiter
    property orbitee : (Orbiter | Nil)
    property orbitee_code
    property code

    def initialize(@code : String, @orbitee_code : String)
    end

    def orbitees
      orbitees = [] of Orbiter
      parent = orbitee
      while !parent.nil?
        orbitees << parent
        parent = parent.orbitee
      end
      orbitees
    end

    def transfers_to(orbitee)
      i = 0
      o = self.orbitee
      loop do
        break if o.nil?
        i += 1
        return i if o == orbitee
        o = o.orbitee
      end
      return -1
    end
  end

  def self.build_orbiters
    orbits = File.read_lines("inputs/06")
    orbiters = [] of Orbiter
    orbits.each do |orbit|
      orbitee, orbiter = orbit.split(')')
      orbiters << Orbiter.new(orbiter, orbitee)
    end
    orbiters << Orbiter.new("COM", "")
    # link orbiters to orbitees
    orbiters.each do |orbiter|
      orbiter.orbitee = orbiters.find do |orbitee|
        orbitee.code == orbiter.orbitee_code
      end
    end
    orbiters
  end

  def self.part1
    orbiters = build_orbiters
    orbiters.map{|o|o.orbitees.size}.sum
  end

  def self.part2
    orbiters = build_orbiters
    santa = orbiters.find{|o|o.code=="SAN"}
    me = orbiters.find{|o|o.code=="YOU"}
    return if santa.nil? || me.nil?
    common = santa.orbitees.find do |orbitee|
      me.orbitees.includes?(orbitee)
    end
    # What is the minimum number of orbital transfers required to move from the object
    # YOU are orbiting to the object SAN is orbiting?
    # (Between the objects they are orbiting - not between YOU and SAN.)
    santa.transfers_to(common) + me.transfers_to(common) - 2
  end

end

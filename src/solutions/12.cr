class Aoc2019::Twelve < Aoc2019::Solution

  class Space
    getter moons

    def initialize( moon_positions : Array(String) )
      @moon_positions = moon_positions
      @moons = Array(Moon).new
      reset
    end

    def reset
      while @moons.any?
        @moons.shift 
      end
      @moon_positions.each do |moon_position|
        if md = /\A<x=(.*), y=(.*), z=(.*)>\z/.match(moon_position)
          x, y, z = md[1].to_i, md[2].to_i, md[3].to_i
          @moons << Moon.new x, y, z
        end
      end
    end

    def step(axis : Char = 'a')
      @moons.each_combination(2) do |moons|
        m1, m2 = moons.shift, moons.shift
        if axis == 'x' || axis == 'a'
          m1.vx = m1.vx + ( m2.px <=> m1.px )
          m2.vx = m2.vx + ( m1.px <=> m2.px )
        end
        if axis == 'y' || axis == 'a'
          m1.vy = m1.vy + ( m2.py <=> m1.py )
          m2.vy = m2.vy + ( m1.py <=> m2.py )
        end
        if axis == 'z' || axis == 'a'
          m1.vz = m1.vz + ( m2.pz <=> m1.pz )
          m2.vz = m2.vz + ( m1.pz <=> m2.pz )
        end
      end
      @moons.each{|m|m.step}
    end

    def energy
      @moons.map{|m|m.energy}.sum
    end
    
    def state(axis : Char = 'a')
      @moons.map{|m|m.state(axis)}.join("|")
    end

    def steps_until_repeat
      # finding steps until repeat independently
      x = steps_until_repeat('x').to_i64
      y = steps_until_repeat('y').to_i64
      z = steps_until_repeat('z').to_i64
      xy_lcm = MathHelpers.lcm(x, y).to_i64
      MathHelpers.lcm(xy_lcm, z).to_i64
    end

    def steps_until_repeat(axis : Char)
      reset
      i = 0
      initial_state = state(axis)
      loop do
        i += 1
        step
        break if initial_state == state(axis)
      end
      i
    end
  end

  class Moon
    property px, py, pz, vx, vy, vz
    def initialize(@px : Int32, @py : Int32, @pz : Int32)
      @vx = 0
      @vy = 0
      @vz = 0
    end

    def step(axis : Char = 'a')
      @px += @vx if axis == 'x' || axis == 'a'
      @py += @vy if axis == 'y' || axis == 'a'
      @pz += @vz if axis == 'z' || axis == 'a'
    end

    def energy
      potential_energy * kinetic_energy
    end

    def potential_energy
      [@px, @py, @pz].map{|n|n.abs}.sum
    end

    def kinetic_energy
      [@vx, @vy, @vz].map{|n|n.abs}.sum
    end

    def to_s
      "pos=<x=#{@px}, y=#{@py}, z=#{@pz}>, vel=<x=#{@vx}, y=#{@vy}, z=#{@vz}>"
    end

    def energy_s
      "pot: #{potential_energy}; kin: #{kinetic_energy}; total: #{energy}"
    end

    def state(axis : Char)
      case axis
      when 'x' then [@px, @vx]
      when 'y' then [@py, @vy]
      when 'z' then [@pz, @vz]
      else [@px, @py, @pz, @vx, @vy, @vz]
      end
    end

  end

  def self.part1
    space = Space.new File.read_lines("inputs/12")
    1000.times do |i|
      space.step
    end
    space.moons.map{|m|m.energy}.sum
  end

  def self.part1_test1
    space = Space.new File.read_lines("inputs/test/12a")
    10.times do |i|
      space.step
    end
    space.moons.map{|m|m.energy}.sum
  end

  def self.part1_test2
    space = Space.new File.read_lines("inputs/test/12b")
    100.times do |i|
      space.step
    end
    space.moons.map{|m|m.energy}.sum
  end
  
  def self.part2
    space = Space.new File.read_lines("inputs/12")
    space.steps_until_repeat
  end

  def self.part2_test1
    space = Space.new File.read_lines("inputs/test/12a")
    space.steps_until_repeat
  end

  def self.part2_test2
    space = Space.new File.read_lines("inputs/test/12b")
    space.steps_until_repeat
  end
end

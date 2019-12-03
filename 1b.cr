# to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.
masses = File.read_lines("1a-input").map{|s|s.to_i32}

def calc_fuel(val)
  (val / 3.0).floor - 2
end

fuel_sum = masses.reduce(0) do |sum, mass|
  fuel = calc_fuel mass
  sum += fuel
  xtra_fuel = calc_fuel fuel
  while xtra_fuel > 0
    sum += xtra_fuel
    xtra_fuel = calc_fuel xtra_fuel
  end
  sum
end

puts fuel_sum

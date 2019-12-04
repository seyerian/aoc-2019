# to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.
masses = File.read_lines("01a-input").map{|s|s.to_i32}

fuel_sum = masses.reduce(0) do |sum, mass|
  fuel = (mass / 3.0).floor - 2
  sum + fuel
end

puts fuel_sum

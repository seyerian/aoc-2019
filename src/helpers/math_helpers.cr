class MathHelpers
  def self.gcd(a : Int32|Int64, b : Int32|Int64)
    b.zero? ? a : gcd(b, a % b)
  end

  def self.lcm(a : Int32|Int64, b : Int32|Int64)
    (a * b) / gcd(a, b)
  end
end

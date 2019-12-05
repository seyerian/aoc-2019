class Four

  MIN=307237
  MAX=769058

  def self.valid? n
    s = n.to_s
    return false unless n >= MIN
    return false unless n <= MAX
    return false unless s.length == 6
    return false unless /(\d)\1/.match?(s)
    last = 10
    s.reverse.each do |c|
      i = c.to_i
      return false if i > last
      last = i
    end
    true
  end

end

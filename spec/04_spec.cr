require "spec"

describe Four do
  describe "::valid?" do
    it "satisfies test values" do
      Four.valid?(111111).should be true
      Four.valid?(223450).should be false
      Four.valid?(123789).should be false
    end
  end
end

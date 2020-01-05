class Aoc2019::TwentyTwo < Aoc2019::Solution

  class SpaceCardDeck
    getter cards

    def initialize
      @cards = Array(Int16|Nil).new
      (0_i16..10006_i16).each do |card|
        @cards << card
      end
    end

    def shuffle(process : String)
      process.split('\n').each do |step|
        # cut -4847
        # deal with increment 74
        # deal into new stack
        case
        when step == "deal into new stack"
          new_stack
        when /\Adeal with increment (.*)\z/.match step
          deal $1.to_i16
        when /\Acut (.*)\z/.match step
          cut $1.to_i16.to_i16
        end
      end
    end

    def factory_order
      @cards.sort!
    end

    def new_stack
      @cards.reverse!
    end

    def cut(n : Int16)
      if n > 0
        @cards.concat @cards.shift(n)
      else
        @cards.pop(n.abs).reverse.each do |card|
          @cards.unshift card
        end
      end
    end

    def deal(n : Int16)
      cards = @cards
      new_cards = Array(Int16|Nil).new(10007, nil)
      pointer = 0
      until cards.empty?
        new_cards[pointer] = cards.shift
        pointer += n
        pointer = pointer - 10007 if pointer > 10006
      end
      @cards = new_cards
    end
  end

  def self.part1
    deck = SpaceCardDeck.new
    deck.shuffle File.read("inputs/22")
    deck.cards.index 2019
  end
end

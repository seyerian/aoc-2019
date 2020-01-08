class Aoc2019::TwentyTwo < Aoc2019::Solution

  class MagicSpaceCardDeck
    @last_card_num : Int64
    def initialize(@card_count : Int64)
      @last_card_num = @card_count - 1
    end

    def reverse_shuffle_offset(process : String, position : Int64, times : Int64 = 1)
      pointer = position
      #puts pointer
      process_reversed = process.split('\n').reverse
      times.times do |i|
        process_reversed.each do |step|
          case
          when step == "deal into new stack"
            #puts "new stack"
            pointer = new_stack pointer
          when /\Adeal with increment (.*)\z/.match step
            #puts "deal inc #{$1}"
            pointer = deal $1.to_i16, pointer
          when /\Acut (.*)\z/.match step
            #puts "cut #{$1}"
            pointer = cut $1.to_i16, pointer
          end
          #puts pointer
        end
      end
      pointer
    end

    private def new_stack(pointer : Int64)
      @last_card_num.to_i64 - pointer
    end

    private def cut(n : Int16, pointer : Int64)
      ptr = pointer.to_i64
      ptr += n
      ptr -= @card_count if ptr > @last_card_num
      ptr += @card_count if ptr < 0
      ptr.to_i64
    end

    private def deal(n : Int16, pointer : Int64)
      #offset = 0
      #until (pointer + offset) % n == 0
      #  offset += 1
      #end
      #(pointer + (offset * @card_count) ) // n

      #i = 0_i64
      #tmp = 0_i64
      #until tmp == pointer
      #  tmp += n
      #  tmp -= @card_count if tmp > @last_card_num
      #  i += 1
      #end
      #i

      offset = 0_i64
      until (offset * @card_count + pointer) % n == 0
        offset += 1
      end
      x = ( pointer + @card_count * offset ) / n
      x.to_i64
    end
  end

  class SpaceCardDeck
    getter cards

    def initialize(@card_count : Int32)
      @cards = Array(Int16|Nil).new
      (0_i16..@card_count-1).each do |card|
        @cards << card
      end
    end

    def shuffle(process : String, track : Int64 | Nil = nil)
      if track
        puts "tracking card:"
        puts cards.index(track) 
        #puts lay_out
      end
      process.split('\n').each do |step|
        next if step.blank?
        case
        when step == "deal into new stack"
          puts "new stack"
          new_stack
        when /\Adeal with increment (.*)\z/.match step
          puts "deal inc #{$1}"
          deal $1.to_i16
        when /\Acut (.*)\z/.match step
          puts "cut #{$1}"
          cut $1.to_i16.to_i16
        end
        if track
          puts cards.index(track)
          #puts lay_out
        end
      end
      nil
    end

    private def new_stack
      @cards.reverse!
    end

    private def cut(n : Int16)
      if n > 0
        @cards.concat @cards.shift(n)
      else
        @cards.pop(n.abs).reverse.each do |card|
          @cards.unshift card
        end
      end
    end

    private def deal(n : Int16)
      cards = @cards
      new_cards = Array(Int16|Nil).new(@card_count, nil)
      pointer = 0
      until cards.empty?
        new_cards[pointer] = cards.shift
        pointer += n
        pointer = pointer - @card_count if pointer > @card_count - 1
      end
      @cards = new_cards
    end

    def lay_out
      puts @cards.join " "
    end
  end

  def self.part1
    deck = SpaceCardDeck.new 10007
    deck.shuffle File.read("inputs/22"), 2019
    deck.cards.index 2019
  end

  def self.part2
    deck = MagicSpaceCardDeck.new 119315717514047
    deck.test
  end
end

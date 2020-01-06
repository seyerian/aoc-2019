require "./src/Aoc2019"

#deck = Aoc2019::TwentyTwo::MagicSpaceCardDeck.new 10007
#puts deck.reverse_shuffle_offset File.read("inputs/22"), 2604

#deck = Aoc2019::TwentyTwo::MagicSpaceCardDeck.new 10
#puts deck.reverse_shuffle_offset "deal with increment 7", 4

#deck = Aoc2019::TwentyTwo::MagicSpaceCardDeck.new 10
#puts deck.reverse_shuffle_offset File.read("inputs/test/22b"), 3

deck = Aoc2019::TwentyTwo::MagicSpaceCardDeck.new 119315717514047
puts deck.reverse_shuffle_offset File.read("inputs/22"), 2020

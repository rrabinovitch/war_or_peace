require 'minitest/autorun'
require 'minitest/pride'
require './lib/card'
require './lib/deck'
require './lib/player'
require './lib/turn'

class TurnTest < Minitest::Test
  def setup
    @card1 = Card.new(:heart, 'Jack', 11)
    @card2 = Card.new(:heart, '10', 10)
    @card3 = Card.new(:heart, '9', 9)
    @card4 = Card.new(:diamond, 'Jack', 11)
    @card5 = Card.new(:heart, '8', 8)
    @card6 = Card.new(:diamond, 'Queen', 12)
    @card7 = Card.new(:heart, '3', 3)
    @card8 = Card.new(:diamond, '2', 2)

    @basic_turn_deck1 = Deck.new([@card1, @card2, @card5, @card8])
    @basic_turn_deck2 = Deck.new([@card3, @card4, @card6, @card7])

    @basic_turn_player1 = Player.new("Megan", @basic_turn_deck1)
    @basic_turn_player2 = Player.new("Aurora", @basic_turn_deck2)

    @basic_turn = Turn.new(@basic_turn_player1, @basic_turn_player2)

    @war_turn_deck1 = Deck.new([@card1, @card2, @card5, @card8])
    @war_turn_deck2 = Deck.new([@card4, @card3, @card6, @card7])
    @war_turn_player1 = Player.new("Megan", @war_turn_deck1)
    @war_turn_player2 = Player.new("Aurora", @war_turn_deck2)

    @war_turn = Turn.new(@war_turn_player1, @war_turn_player2)

    @mad_card6 = Card.new(:diamond, '8', 8)

    @mad_turn_deck1 = Deck.new([@card1, @card2, @card5, @card8])
    @mad_turn_deck2 = Deck.new([@card4, @card3, @mad_card6, @card7])

    @mad_turn_player1 = Player.new("Megan", @mad_turn_deck1)
    @mad_turn_player2 = Player.new("Aurora", @mad_turn_deck2)

    @mad_turn = Turn.new(@mad_turn_player1, @mad_turn_player2)
  end

  def test_it_exists
    assert_instance_of Turn, @basic_turn
  end

  def test_it_has_two_players
    assert_equal @basic_turn_player1, @basic_turn.player1
    assert_equal @basic_turn_player2, @basic_turn.player2
  end

  def test_it_starts_with_no_spoils_of_war
    assert_empty @basic_turn.spoils_of_war
  end

  def test_it_can_identify_turn_type_when_basic
    assert_equal :basic, @basic_turn.type
  end

  def test_it_can_identify_turn_type_when_war
    assert_equal :war, @war_turn.type
  end

  def test_it_can_identify_turn_type_when_mutually_assured_destruction
    assert_equal :mutually_assured_destruction, @mad_turn.type
  end

  def test_it_can_identify_a_turn_winner_when_basic
    assert_equal @basic_turn_player1, @basic_turn.winner
  end

  def test_it_can_identify_a_turn_winner_when_war
    assert_equal @war_turn_player2, @war_turn.winner
  end

  def test_there_is_no_turn_winner_when_mutually_assured_destruction
    assert_equal "No Winner", @mad_turn.winner
  end

  def test_pile_cards_method_sends_top_card_from_each_players_deck_to_spoils_of_war_when_turn_type_is_basic
    @basic_turn.pile_cards
    assert_equal [@card1, @card3], @basic_turn.spoils_of_war
    assert_equal [@card2, @card5, @card8], @basic_turn_player1.deck.cards
    assert_equal [@card4, @card6, @card7], @basic_turn_player2.deck.cards
  end

  def test_pile_cards_method_sends_top_three_cards_from_each_players_deck_to_spoils_of_war_when_turn_type_is_war
    @war_turn.pile_cards

    assert @war_turn.spoils_of_war.include?(@card1)
    assert @war_turn.spoils_of_war.include?(@card4)
    assert @war_turn.spoils_of_war.include?(@card2)
    assert @war_turn.spoils_of_war.include?(@card3)
    assert @war_turn.spoils_of_war.include?(@card5)
    assert @war_turn.spoils_of_war.include?(@card6)
    assert_equal 6, @war_turn.spoils_of_war.count
  end

  def test_pile_cards_method_removes_top_three_cards_from_each_players_deck_and_from_play_when_turn_type_is_mutually_assured_destruction
    @mad_turn.pile_cards

    assert_empty @mad_turn.spoils_of_war

    assert_equal [@card8], @mad_turn.player1.deck.cards
    assert_equal [@card7], @mad_turn.player2.deck.cards
  end

  def test_it_awards_spoils_of_war_to_winner_of_turn_when_type_is_basic
    winner = @basic_turn.winner
    @basic_turn.pile_cards
    @basic_turn.award_spoils(winner)

    assert @basic_turn_player1.deck.cards.include?(@card2)
    assert @basic_turn_player1.deck.cards.include?(@card5)
    assert @basic_turn_player1.deck.cards.include?(@card8)
    assert @basic_turn_player1.deck.cards.include?(@card1)
    assert @basic_turn_player1.deck.cards.include?(@card3)
    assert_equal 5, @basic_turn_player1.deck.cards.count

    assert @basic_turn_player2.deck.cards.include?(@card4)
    assert @basic_turn_player2.deck.cards.include?(@card6)
    assert @basic_turn_player2.deck.cards.include?(@card7)

    assert_equal 3, @basic_turn_player2.deck.cards.count

    assert_empty @basic_turn.spoils_of_war
  end

  def test_it_awards_spoils_of_war_to_winner_of_turn_when_type_is_war
    winner = @war_turn.winner

    @war_turn.pile_cards
    @war_turn.award_spoils(winner)

    assert_equal [@card8], @war_turn_player1.deck.cards

    assert @war_turn_player2.deck.cards.include?(@card7)
    assert @war_turn_player2.deck.cards.include?(@card1)
    assert @war_turn_player2.deck.cards.include?(@card4)
    assert @war_turn_player2.deck.cards.include?(@card2)
    assert @war_turn_player2.deck.cards.include?(@card3)
    assert @war_turn_player2.deck.cards.include?(@card5)
    assert @war_turn_player2.deck.cards.include?(@card6)
    assert_equal 7, @war_turn_player2.deck.cards.count

    assert_empty @war_turn.spoils_of_war
  end
end

require "rails_helper"

RSpec.describe Word, type: :model do
  before(:each) do
  end

  describe "transition_words_through_substitution" do
    it "should return each valid transition word generated through letter substitution with the position changed, and do not return self" do
      apple = Word.new('apple', 'lemon')

      result = apple.transition_words_through_substitution
      expected = [['ample',1],['apply',4]]
      expect((expected - result).empty?).to be true
      expect(result.include?('apple')).to be false
    end
  end

  describe "transition_words_through_reordering" do
    it "should return an array of valid words generated through reordering, and do not return self" do
      apple = Word.new('apple', 'lemon') 

      result = apple.transition_words_through_reordering
      expected = [['appel',nil],['pepla',nil]]
      expect((expected - result).empty?).to be true
      expect(result.include?('apple')).to be false
    end
  end

  describe "transition_words" do
    it "should return an array of valid transition words, and do not return self" do
      apple = Word.new('apple', 'lemon') 

      result = apple.transition_words
      expected = [['ample',1],['apply',4],['appel',nil],['pepla',nil]]
      expect((expected - result).empty?).to be true
      expect(result.include?('apple')).to be false
    end
  end

  describe "match_count" do
    it "should return count of matching letters regardless of index" do
      expect(Word.new('apple', 'apply').match_count).to eq(4)
      expect(Word.new('apple', 'papel').match_count).to eq(5)
      expect(Word.new('apple', 'patch').match_count).to eq(2)
      expect(Word.new('apple', 'zzzzz').match_count).to eq(0)
    end
  end

  describe "full_match?" do
    it "should return whether there are only full matches" do
      expect(Word.new('apple', 'apply').only_full_match?).to be true
      expect(Word.new('apple', 'papel').only_full_match?).to be false
      expect(Word.new('apple', 'patch').only_full_match?).to be false
      expect(Word.new('apple', 'zzzzz').only_full_match?).to be true
    end
  end

  describe "count_improvement" do
    it "should return true if the difference of matches of the new word if greater than the counr of the original word" do
      apple = Word.new('apple', 'lemon')
      expect(apple.count_improvement?(Word.new('ample', 'lemon'))).to be true
      expect(apple.count_improvement?(Word.new('amply', 'lemon'))).to be false
      expect(apple.count_improvement?(Word.new('appel', 'lemon'))).to be false
      expect(apple.count_improvement?(Word.new('pepla', 'lemon'))).to be false
    end
  end

  describe "transition_words_closer_to_target" do
    it "should return array of transition word objects closet to the target, sorted by no. of matching indexes" do
      place = Word.new('place', 'plant')
      expect(place.transition_words_closer_to_target.map(&:word)).to eq(['plane','plate']) #plane should come first

      breed = Word.new('breed','plant')
      result = breed.transition_words_closer_to_target.map(&:word)
      p result
      expected = ['preed','bleed','treed','bread']
      expect((result - expected).empty?).to be true
      expect((expected - result).empty?).to be true
      expect(result.index('preed') < result.index('treed')).to be true
      expect(result.index('bleed') < result.index('treed')).to be true

    end
  end

end
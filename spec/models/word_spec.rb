require "rails_helper"

RSpec.describe Word, type: :model do
  before(:each) do
  end

  describe "initialize" do
    it "should initialize an object with a word, a target and a dictionary, and the letter-match-count between the word and target" do
      dict_words = ['apple', 'ample', 'apply', 'lemon', 'appel', 'pepla']
      dict = Dict.new(dict_words)

      apple = Word.new('apple', 'lemon', dict)
      expect(apple.word).to eq('apple')
      expect(apple.target).to eq('lemon')
      expect(apple.dict).to eq(dict)
      expect(apple.match_count).to eq(2)
    end
  end

  describe "transition_words_through_substitution" do
    it "should return each valid transition word generated through letter substitution with the position changed, and do not return self" do
      dict_words = ['apple', 'ample', 'apply', 'lemon', 'appel', 'pepla']
      dict = Dict.new(dict_words)
      apple = Word.new('apple', 'lemon', dict)
      #apple = Word.new('apple', 'lemon')

      result = apple.transition_words_through_substitution
      expected = [['ample',1],['apply',4]]
      expect((expected - result).empty?).to be true
      expect(result.include?('apple')).to be false
    end
  end

  describe "transition_words_through_reordering" do
    it "should return an array of valid words generated through reordering, and do not return self" do
      dict_words = ['apple', 'ample', 'apply', 'lemon', 'appel', 'pepla']
      dict = Dict.new(dict_words)
      apple = Word.new('apple', 'lemon', dict) 

      result = apple.transition_words_through_reordering
      expected = [['appel',nil],['pepla',nil]]
      expect((expected - result).empty?).to be true
      expect(result.include?('apple')).to be false
    end
  end

  describe "transition_words" do
    it "should return an array of valid transition words, and do not return self" do
      dict_words = ['apple', 'ample', 'apply', 'lemon', 'appel', 'pepla']
      dict = Dict.new(dict_words)
      apple = Word.new('apple', 'lemon', dict)

      result = apple.transition_words
      expected = [['ample',1],['apply',4],['appel',nil],['pepla',nil]]
      expect((expected - result).empty?).to be true
      expect(result.include?('apple')).to be false
    end
  end

  describe "match_count" do
    it "should return count of matching letters regardless of index" do
      dict_words = ['apple', 'apply', 'papel', 'patch', 'zzzzz']
      dict = Dict.new(dict_words)

      expect(Word.new('apple', 'apply', dict).match_count).to eq(4)
      expect(Word.new('apple', 'papel', dict).match_count).to eq(5)
      expect(Word.new('apple', 'patch', dict).match_count).to eq(2)
      expect(Word.new('apple', 'zzzzz', dict).match_count).to eq(0)
    end
  end

  describe "full_match?" do
    it "should return whether there are only full matches" do
      dict_words = ['apple', 'apply', 'papel', 'patch', 'zzzzz']
      dict = Dict.new(dict_words)

      expect(Word.new('apple', 'apply', dict).only_full_match?).to be true
      expect(Word.new('apple', 'papel', dict).only_full_match?).to be false
      expect(Word.new('apple', 'patch', dict).only_full_match?).to be false
      expect(Word.new('apple', 'zzzzz', dict).only_full_match?).to be true
    end
  end

  describe "count_improvement" do
    it "should return true if the difference of matches of the new word if greater than the counr of the original word" do
      dict_words = ['apple', 'ample', 'apply', 'lemon', 'appel', 'pepla']
      dict = Dict.new(dict_words)
      apple = Word.new('apple', 'lemon', dict)
      
      expect(apple.count_improvement?(Word.new('ample', 'lemon', dict))).to be true
      expect(apple.count_improvement?(Word.new('amply', 'lemon', dict))).to be false
      expect(apple.count_improvement?(Word.new('appel', 'lemon', dict))).to be false
      expect(apple.count_improvement?(Word.new('pepla', 'lemon', dict))).to be false
    end
  end

  describe "transition_word_objects" do
    it "should return array of transition word objects, each has the same target word, uses the same dict, and a path that includes the prior transition word(s)" do
      dict_words = ['apple', 'ample', 'apply', 'lemon', 'appel', 'pepla']
      dict = Dict.new(dict_words)
      apple = Word.new('apple', 'lemon', dict)
      
      result = apple.transition_word_objects
      result_words = result.map{|w| w.word}

      expected_words = ['apply', 'ample', 'appel', 'pepla']
      expect((result_words - expected_words).empty?).to be true
      expect((expected_words - result_words).empty?).to be true
      
      result_targets = result.map{|w| w.target}
      expect(result_targets.all?{|w| w == 'lemon'}).to be true

      result_dicts = result.map{|w| w.dict}
      expect(result_dicts.all?{|d| d == dict}).to be true

      result_paths = result.map{|w| w.path}
      expect(result_paths.all?{|p| p == ['apple']}).to be true
    end
  end

  describe "transition_words_closer_to_target" do
    it "should return array of transition word objects closet to the target, sorted by no. of matching indexes" do
      dict_words = ["place", "plant", "glace", "peace", "plage", "plane", "plate", "plack", "caple"]
      dict = Dict.new(dict_words)
      place = Word.new('place', 'plant')
      expect(place.transition_words_closer_to_target.map(&:word)).to eq(['plane','plate']) #plane should come first

      dict_words = ["creed", "dreed", "freed", "greed", "preed", "treed", "bleed", "bread", "breid", "breem", "breer", "brees", "brede"]
      dict = Dict.new(dict_words)
      breed = Word.new('breed','plant')

      result = breed.transition_words_closer_to_target.map(&:word)
      expected = ['preed','bleed','treed','bread']
      expect((result - expected).empty?).to be true
      expect((expected - result).empty?).to be true
      expect(result.index('preed') < result.index('treed')).to be true
      expect(result.index('bleed') < result.index('treed')).to be true

    end
  end

end
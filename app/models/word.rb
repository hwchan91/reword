require 'pry'

class Word
  require_relative "dict"
  attr_accessor :word, :dict, :path, :index_changed

  def initialize(word, dict = nil, path = [], index_changed = nil)
    @word = word
    @dict = (dict.nil?) ? Dict.new : dict
    @path = path
    @index_changed = index_changed
  end

  def transition_words_through_substitution
    output = []
    @word.length.times do |position|
      ('a'..'z').to_a.each do |substitute|
        test_word = @word.clone
        test_word[position] = substitute
        output << [test_word, position] if @dict.valid?(test_word)
      end
    end
    output.uniq.reject{|w| w[0] == @word}
  end

  def transition_words_through_reordering
    output = []
    permutations = @word.split("").permutation.to_a.map{|arr| arr.join()}
    permutations.each do |word|
      output << [word, nil] if @dict.valid?(word)
    end
    output.uniq.reject{|w| w[0] == @word}
  end

  def transition_words
    output = self.transition_words_through_substitution
    output += self.transition_words_through_reordering
  end

  def partial_match_count(word_to_compare)
    word_letters = @word.split("")
    unmatch_letters = word_to_compare.split("")
    word_letters.each do |letter|
      unmatch_letters.delete_at(unmatch_letters.index(letter) || unmatch_letters.length)
    end
    word_to_compare.length - unmatch_letters.length
  end

  def full_match_count(word_to_compare)
    count = 0
    word_to_compare.length.times do |i|
      count += 1 if @word[i] == word_to_compare[i]
    end
    count
  end

  def only_full_match?(word_to_compare)
    full_match_count(word_to_compare) == partial_match_count(word_to_compare)
  end

  #should reduce rating by length of path of compared word; full_match set as '+1'
  def match_count(word_to_compare)
    count = partial_match_count(word_to_compare.word)
    count += 1 if only_full_match?(word_to_compare.word) and count != 0
    count -= word_to_compare.path.length
    count == path.length #TRY1: deduct own path length as well
    count
  end

  def best_match_count(words_to_compare)
    best = 0 # [0, nil]
    words_to_compare.each do |comparison|
      comparison_best = match_count(comparison)
      if comparison_best > best
        best = comparison_best
      end 
    end
    best
  end

  def transition_word_objects
    @transition_word_objects ||= generate_transition_word_objects
  end
  
  def generate_transition_word_objects
    output = []
    path = @path.clone.push(@word)
    transition_words.each do |word, index_changed|
      output << Word.new(word, @dict, path, index_changed)
    end
    output
  end

  def transition_words_closer_to_target(words_to_compare)
    return @sorted_output if @sorted_output
    output = []
    original_best = best_match_count(words_to_compare)
    transition_word_objects.each do |transition_word|
      transition_word_best = transition_word.best_match_count(words_to_compare)
      output << [transition_word, transition_word_best] if transition_word_best > original_best - 1 # -1 for one step in the right direction
    end
    @sorted_output = output.sort_by{|word, best_count| best_count}.reverse.map{|word, best_count| word}
  end

  def getting_closer?(words_to_compare)
    transition_words_closer_to_target(words_to_compare).length > 0
  end

end

#binding.pry
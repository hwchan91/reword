require 'pry'

class Word
  require_relative "dict"
  attr_accessor :word, :target, :dict, :match_count, :path

  def initialize(word, target, dict = Dict.new, path = [], index_changed = nil)
    @word = word
    @target = target
    @dict = dict
    @match_count = get_match_count
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

  def get_match_count
    word_letters = @word.split("")
    unmatch_letters = @target.split("")
    word_letters.each do |letter|
      unmatch_letters.delete_at(unmatch_letters.index(letter) || unmatch_letters.length)
    end
    @target.length - unmatch_letters.length
  end

  def full_match_count
    count = 0
    @target.length.times do |i|
      count += 1 if @word[i] == @target[i]
    end
    count
  end

  def only_full_match?
    full_match_count == @match_count
  end

  def count_improvement?(transition_word)
    (transition_word.match_count - @match_count) > 0
  end

  def transition_word_objects
    @transition_word_objects ||= generate_transition_word_objects
  end
  
  def generate_transition_word_objects
    output = []
    path = @path.clone.push(@word)
    transition_words.each do |word, index_changed|
      output << Word.new(word, @target, @dict, path, index_changed)
    end
    output
  end

  def transition_words_closer_to_target
    return @sorted_output if @sorted_output
    output = []
    transition_word_objects.each do |word|
      output << word if self.count_improvement?(word)
    end
    full_match_words = output.select{ |word| word.only_full_match? }
    partial_match_words = output - full_match_words 
    @sorted_output = full_match_words + partial_match_words
  end

  def getting_closer?
    transition_words_closer_to_target.length > 0
  end

  def match_target?
    @word == @target
  end

end

#binding.pry
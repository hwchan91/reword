module Transitable
  extend ActiveSupport::Concern

  def transition_word_objects
    @transition_word_objects ||= generate_transition_word_objects
  end

  def transition_words
    # output = transition_words_through_substitution
    # unless no_reorder
    #   output += transition_words_through_reordering
    # end
    # output

    transition_words = Rails.cache.fetch("transition_words") { JSON.parse(File.read('transition_words.json')) }
    transition_words[word]
  end

  private
  def transition_words_through_substitution
    output = []
    word.length.times do |position|
      ('a'..'z').to_a.each do |substitute|
        test_word = word.dup
        test_word[position] = substitute
        output << [test_word, position] if dict.valid?(test_word)
      end
    end
    output.uniq.reject{|w| w[0] == word}
  end

  def transition_words_through_reordering
    output = []
    permutations = word.split("").permutation.to_a.map{|arr| arr.join()}
    permutations.each do |word|
      output << [word, nil] if dict.valid?(word)
    end
    output.uniq.reject{|w| w[0] == word}
  end


  def generate_transition_word_objects
    output = []
    path = @path.clone.push(word) #seems Rails' path has a special meaning, thus calling path instead of @path would return nil
    transition_words.each do |word, index_changed|
      output << Word.new(word, dict, no_reorder, path, index_changed)
    end
    output
  end
end

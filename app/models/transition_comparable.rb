module TransitionComparable 
  extend ActiveSupport::Concern

  def getting_closer?(words_to_compare)
    transition_words_closer_to_target(words_to_compare).length > 0
  end

  def transition_words_closer_to_target(words_to_compare)
    return @sorted_output if @sorted_output
    original_best = best_match_count(words_to_compare)
    output = transition_word_objects.select { |transition_word| transition_word.best_match_count(words_to_compare) > original_best - 1 }
    @sorted_output = output.sort_by{|word, best_count| best_count}.reverse.map{|word, best_count| word}
  end
    
  def best_match_count(words_to_compare)
    words_to_compare.map { |comparison| match_count(comparison) }.max
  end

  private
  def match_count(word_to_compare)
    matches = compare(word_to_compare.word)

    unless no_reorder
      count = partial_or_full_match_count(matches) - word_to_compare.path.length - path.length
      count += 1 if only_full_match?(matches) and count != 0
      count
    else
      count = full_match_count(matches) - word_to_compare.path.length - path.length
    end
  end

  def partial_or_full_match_count(matches)
    partial_match_count(matches) + full_match_count(matches)
  end

  def full_match_count(matches)
    matches.full_match_indexes.size
  end

  def partial_match_count(matches)
    matches.partial_match_indexes.size
  end

  def only_full_match?(matches)
    partial_match_count(matches) == 0
  end
end

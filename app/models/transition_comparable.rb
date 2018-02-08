module TransitionComparable
  extend ActiveSupport::Concern

  def getting_closer?(word_to_compare)
    @getting_closer ||= transition_words_closer_to_target(word_to_compare).length > 0
  end

  def transition_words_closer_to_target(word_to_compare)
    return @sorted_output if @sorted_output
    original_best = match_count(word_to_compare)
    output = transition_word_objects.select { |transition_word| transition_word.match_count(word_to_compare) > original_best }
    @sorted_output = output.sort_by{|word| word.match_count(word_to_compare)}.reverse #sort seems to make it slightly faster, but very small difference
  end

  # def best_match_count(words_to_compare)
  #   @best_match_count ||= words_to_compare.map{ |comparison| match_count(comparison) }.max
  # end

  # private
  def match_count(word_to_compare)
    return @count if @count
    matches = compare(word_to_compare.word)

    unless no_reorder
      count = partial_or_full_match_count(matches) - word_to_compare.path.length - path.length
      count += 1 if only_full_match?(matches) and count != 0
      count
    else
      count = full_match_count(matches) - word_to_compare.path.length - path.length
    end
    @count = count
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

module WordComparable
  extend ActiveSupport::Concern

  def compare(target_word)
    OpenStruct.new({
      full_match_indexes: full_match_indexes(target_word),
      partial_match_indexes: partial_match_indexes(target_word)
    })
  end

  private
  def full_match_indexes(target_word)
    target_word.split('').map.each_with_index{ |letter, index| letter == word[index] ? index : nil }.compact
  end

  def partial_match_indexes(target_word)
    word_letters = word.split("")
    compare_letters = target_word.split("")
    matched_indexes = []
    full_match_indexes(target_word).each{|index| word_letters[index] = nil}

    word_letters.each do |letter|
      if matching_index = compare_letters.index(letter)
        matched_indexes.push(matching_index)
      end
    end
    matched_indexes
  end
end

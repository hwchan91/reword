 module Choosable
  extend ActiveSupport::Concern

  # For front-end, possible transition choice
  def choices(history)
    hash = {}
    transition_words_not_used(history).each do |word, index|
      if hash[index] 
        hash[index] << word
      else
        hash[index] = [word]
      end
    end
    hash
  end

  #prevent hack
  def valid_transition?(new_word, history)
    transition_words_not_used(history).map{|word, index| word}.include?(new_word)
  end

  private
  def transition_words_not_used(history)
    transition_words.select{|word, index| !history.include?(word)}
  end
end

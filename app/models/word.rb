require 'pry'
# module Dict
  
#   def self.generate
#     dict = {}
#     text = File.open('./wordlist.txt').read
#     text.gsub!(/\r\n?/, "\n")
#     text.each_line do |line|
#         word = line.strip()
#         dict[word] = word
#     end
#     dict
#   end
#   @@dict = Dict.generate

#   def self.valid?(word)
#     @@dict[word]
#   end
# end


class Word
  require_relative "dict"
  attr_accessor :word, :match_count, :path

  def initialize(word, target, path = [], index_changed = nil)
    @word = word
    @target = target
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
        output << [test_word, position] if Dict.valid?(test_word)
      end
    end
    output.uniq.reject{|w| w[0] == @word}
  end

  def transition_words_through_reordering
    output = []
    permutations = @word.split("").permutation.to_a.map{|arr| arr.join()}
    permutations.each do |word|
      output << [word, nil] if Dict.valid?(word)
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
      output << Word.new(word, @target, path, index_changed)
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

class WordTrek
  attr_accessor :top_stack, :bottom_stack, :curr_stack, :new_transition_words, :words_in_curr_stack, :words_in_to_be_added, :to_be_added

  def initialize(starting_word, target_word)
    @top_stack = [Word.new(starting_word, target_word)]
    @bottom_stack = [Word.new(target_word, starting_word)]
    @curr_stack = [@bottom_stack, @top_stack].cycle
    @curr_stack = @curr_stack.next
    @result = nil
  end

  def switch_stack
    @curr_stack.next
  end

  def add_transition_to_stack(wordbase = @curr_stack) #should not be curr_stack but the front of new trasition words
    @to_be_added = []
    catch :found_solution do 
      populate_words_to_be_added
      clear_curr_stack_cache

      #check_if_reached_target
      check_if_no_solution
      @curr_stack += @to_be_added
    end
    @result if @result
  end

  def populate_words_to_be_added(wordbase = @curr_stack)
    wordbase.each do |word|
      word.transition_word_objects.each do |transition_word|
        check_if_reached_target(transition_word)
        add_if_new(transition_word)
      end
      clear_to_be_added_cache

      recursive_call_on_words_getting_closer(word) if word.getting_closer?
    end
  end

  def clear_to_be_added_cache
    remove_instance_variable(:@words_in_to_be_added)if @words_in_to_be_added
  end

  def clear_curr_stack_cache
    remove_instance_variable(:@words_in_curr_stack) if @words_in_curr_stack
  end

  def add_if_new(word)
    @to_be_added.push(word) if new_word?(word)
  end

  def check_if_reached_target(word)
    if word.match_target?
      @result = word
      throw :found_solution
    end
  end

  def check_if_no_solution
    if @to_be_added.empty?
      @result = "no solution" 
      throw :found_solution
    end
  end

  def recursive_call_on_words_getting_closer(word)
    words_closer = word.transition_words_closer_to_target
    populate_words_to_be_added(words_closer)
  end

  def new_word?(word)
    @words_in_curr_stack ||= words_in_stack(@curr_stack)
    @words_in_to_be_added ||= words_in_stack(@to_be_added)

    not_in_stack = !@words_in_curr_stack.include?(word.word)
    not_in_to_be_added = !@words_in_to_be_added.include?(word.word)
    not_in_stack and not_in_to_be_added
  end


  def words_in_stack(stack)
    (stack.empty?) ? [] : stack.map(&:word)
  end


end

# w = WordTrek.new('apple', 'lemon')
# w.add_transition_to_stack
# w.add_transition_to_stack
# w.words_in_stack(w.curr_stack).length

w = WordTrek.new('aaaaa', 'zzzzz')
w.add_transition_to_stack


binding.pry

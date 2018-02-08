class WordTrek
  require_relative "dict"
  require_relative "word"
  attr_accessor  :to_be_added, :new_transition_words, :words_in_curr_stack, :words_in_to_be_added, :result
  include SideManager

  def initialize(starting_word, target_word, limit = nil, dict = nil, no_reorder = false)
    @limit = limit
    @starting_word = Word.new(starting_word, dict, no_reorder)
    @target_word = Word.new(target_word, dict, no_reorder)
    top_front = [@starting_word]
    bottom_front = [@target_word]
    @fronts = [top_front, bottom_front]

    top_stack = bottom_stack = []
    @stacks = [top_stack, bottom_stack]
    @curr_side_index = 0

    @result = (starting_word.length != target_word.length) ? ["no solution"] : []
  end

  def solve
    turn = 1
    if @starting_word.dict.valid?(@starting_word.word).nil? || @target_word.dict.valid?(@target_word.word).nil?
      @result << 'no solution'
    else
      until @result[0] == 'no solution' or @result.length > 0
        return_no_solution if @result.empty? and @limit and turn > @limit
        find_solution
        switch_sides
        turn += 1
      end
    end
    return_solution
  end

  private
      def find_solution
        catch :found_solution do
          propagate_front
          check_if_no_solution
          move_front
        end
        return_solution if @result
      end

          def propagate_front(front = curr_front, stack = curr_stack, to_be_added = @to_be_added = [])
            wordbase = front.clone #unlink from the front so that the front would remain the same
            wordbase.each do |word|
              if word.getting_closer?(stack_target)
                words_closer = word.transition_words_closer_to_target(stack_target) #start or target
                words_closer_not_already_included = words_closer.select{|word| new_word?(word, front, stack)} #the words needs to be determined before anything new gets added into to_be_added
              end
              # puts 'current word', word.word

              word.transition_word_objects.each do |transition_word|
                check_if_reached_target(transition_word)
                to_be_added << transition_word if new_word?(transition_word, front, stack)
              end
              # puts 'transition_words'
              # puts word.transition_word_objects.map(&:word)
              clear_to_be_added_cache

              # puts 'word.getting_closer?'
              # puts word.getting_closer?([opposite_side.first])

              # puts 'words_closer_not_already_included' if word.getting_closer?([opposite_side.first])
              # puts words_closer_not_already_included.map(&:word) if word.getting_closer?([opposite_side.first])
              recursive_call_on_words_getting_closer(words_closer_not_already_included, stack, to_be_added) if word.getting_closer?(stack_target) #recursive call should be after add_if_new for optimal path
            end
            to_be_added
          end

              def check_if_reached_target(word)
                opposite_side.each do |word_in_oppo|
                  if word.word  == word_in_oppo.word
                    @result << [word, word_in_oppo]
                    throw :found_solution #uncomment to return more solutions
                  end
                end
              end

              def clear_to_be_added_cache
                remove_instance_variable(:@words_in_to_be_added)if @words_in_to_be_added
              end

              def recursive_call_on_words_getting_closer(words_closer_not_already_included, stack, to_be_added)
                propagate_front(words_closer_not_already_included, stack, to_be_added)
              end

                  def new_word?(word, curr_front, curr_stack)
                    @words_in_curr_stack ||= words_in_stack(curr_stack)
                    @words_in_curr_front ||= words_in_stack(curr_front)
                    @words_in_to_be_added ||= words_in_stack(@to_be_added)

                    not_in_stack = !@words_in_curr_stack.include?(word.word)
                    not_in_front = !@words_in_curr_front.include?(word.word)
                    not_in_to_be_added = !@words_in_to_be_added.include?(word.word)
                    not_in_stack and not_in_front and not_in_to_be_added
                  end

                      def words_in_stack(stack)
                        (stack.empty?) ? [] : stack.map(&:word)
                      end

          def check_if_no_solution
            if @to_be_added.empty?
              return_no_solution
              throw :found_solution
            end
          end

          def return_no_solution
            @result << "no solution"
          end

          def move_front
            clear_curr_cache
            self.curr_stack += self.curr_front
            self.curr_front = @to_be_added
          end

              def clear_curr_cache
                remove_instance_variable(:@words_in_curr_front) if @words_in_curr_front
                remove_instance_variable(:@words_in_curr_stack) if @words_in_curr_stack
              end

      def switch_sides
        @curr_side_index = (@curr_side_index + 1) % 2
      end

      def return_solution
        return 'no solution' if @result[0] == 'no solution'
        results = @result.map do |result|
          first_half = result[0].path
          second_half = result[1].path
          solution = first_half + [result[0].word] + second_half.reverse
          solution.reverse! if @curr_side_index == 0
          solution
        end
        results.first #results returns an array
      end
end

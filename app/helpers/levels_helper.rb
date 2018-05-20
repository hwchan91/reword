module LevelsHelper
  def choosable?(index)
    @choices[index] ? 'choosable' : 'unchoosable'
  end

  def number_of_prev_steps_exceed(num)
    @history.length > num
  end

  def range_of_prev_steps(num)
    (-(num + 1)..-2).to_a
  end

  def history_at(number_of_prev_steps)
    @history[number_of_prev_steps]
  end

  def distance_from_curr(number_of_prev_steps)
    if @undo
       -(number_of_prev_steps) - 1
    else
      -(number_of_prev_steps) - 2
    end
  end

  def backstep(number_of_prev_steps)
    -(number_of_prev_steps) - 1
  end

  def highlight_letter_if_changed(letter_index, changed_index)
    return "highlight" if reorder_letters?(changed_index)
    "highlight" if letter_index == changed_index
  end

  def reorder_letters?(changed_index)
    changed_index.nil? #nil signifies reorder, "none"(defined below) signifies starting word
  end

  def describe_action(changed_index)
    changed_index ? "switch_index_#{changed_index}" : "reorder_letters"
  end

  def used_word(record)
    record["word"]
  end

  def changed_index(record)
    changed_index = record["changed_index"]
    case changed_index
    when nil then "none"
    when "" then nil
    else changed_index.to_i
    end
  end

  def remaining_steps_to_optimal
    @level.path.length - @history.length
  end

  def within_optimal?
    @history.length <= @level.path.length
  end

  def within_limit?
    @history.length < @limit
  end

  def steps_before_limit_after_optimal
    if @history.length <= @level.path.length
      @limit - @level.path.length - 1
    else
      @limit - @history.length
    end
  end

  def limit_exist_after_optimal
    @limit != @level.path.length
  end

  def match_status(index)
    if @matches.full_match_indexes.include?(index)
      "full_match"
    elsif @matches.partial_match_indexes.include?(index)
      "partial_match"
    else
      "not_match"
    end
  end

  def level_id_or_zen
    @level.id <= ENV['DEFAULT_LEVELS'].to_i ? @level.id : 'zen'
  end

  def get_hint
    hint = @level.try(:hint)
    return if hint.nil?
    hint.any? ? hint : nil
  end

  def main_color
    return '#8be0de' unless @level
    id =  @level.id
    return '#8be0de' if id.between?(1,10)
    return '#1e488c' if id.between?(11,20)
    return '#6e845c' if id.between?(21,30)
    return '#580b59' if id.between?(31,40)
    return 'black' if id.between?(41,50)
    '#d1bfba'
  end

  def highlight_color
    return 'rgb(50, 163, 202)' unless @level
    id =  @level.id
    return 'rgb(50, 163, 202)' if id.between?(1,10)
    return 'rgb(112, 159, 204)' if id.between?(11,20)
    return 'rgb(204, 206, 97)' if id.between?(21,30)
    return 'rgb(119, 126, 168)' if id.between?(31,40)
    return 'rgb(104, 53, 53)' if id.between?(41,50)
    'rgb(63, 56, 54)'
  end

  def display_hint?
    return false if @level.id == 9999
    (@level.path.count - 1)/2 > 0
  end

  def more_hints_available?
    @hints_count < (@level.path.count - 1)/2
  end
end

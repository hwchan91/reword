module SideManager
  extend ActiveSupport::Concern

  def curr_stack
    @stacks[@curr_side_index]
  end

  def curr_stack=(result)
    @stacks[@curr_side_index] = result
  end

  def curr_front
    @fronts[@curr_side_index]
  end

  def curr_front=(result)
    @fronts[@curr_side_index] = result
  end

  def opposite_stack
    @stacks[(@curr_side_index + 1) % 2]
  end

  def opposite_front
    @fronts[(@curr_side_index + 1) % 2]
  end

  def opposite_side
    opposite_stack + opposite_front #try sorting so that the words with the highest match are at the front of the array so that they get returned first
  end
end

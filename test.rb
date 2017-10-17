class Test
  attr_accessor :a, :b, :arr, :i
  def initialize
    @arr = [[1],[2]]
    @i = 0
  end

  def get_elem
    @arr[@i]
  end

  # def get_elem=(result)
  #    @arr[@i] = result
  # end

  def push_to_arr(j)
    p get_elem
    self.get_elem = self.get_elem + [j]
  end

end
class Word
  require_relative "dict"
  attr_accessor :word, :dict, :path, :index_changed, :no_reorder
  include Definitable, Choosable, WordComparable, Transitable, TransitionComparable

  def initialize(word, dict = nil, no_reorder = false, path = [], index_changed = nil)
    @word = word
    @dict = (dict.nil?) ? Dict.new('common') : dict #cannot set default dict = Dict.new, because WordTrek passess nil as dict instead of nothing
    @path = path
    @index_changed = index_changed
    @no_reorder = no_reorder
  end

end

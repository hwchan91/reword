class Word
  require_relative "dict"
  attr_accessor :word, :dict, :path, :index_changed, :no_reorder
  include Definitable, Choosable, WordComparable, Transitable, TransitionComparable


  WORDS_TO_REJECT = %w(other those these them they have slang sports common lying human group whose parts eaten aside fully being under about along often class state such that only usage notes from into with what will type kind used much make made else this your upon been were with good show shows when mode more side word using having little single person create leave names added while which order cause above place during around also simple where takes than most take here over very each after move come part went before their then sides quite note just some time give body past tense simple plural called term series near thing whole things large small little doing name solid liquid thin thick light heavy real both lower higher high give given form great long short scots less open close genus ears there large enter shape shaped menas work feet items major main same manner liver hold held placed keep prone taken fact either back down space).freeze

  def initialize(word, dict = nil, no_reorder = false, path = [], index_changed = nil)
    @word = word
    @dict = (dict.nil?) ? Dict.new('common') : dict #cannot set default dict = Dict.new, because WordTrek passess nil as dict instead of nothing
    @path = path
    @index_changed = index_changed
    @no_reorder = no_reorder
  end

  def self.common?(word)
    bad_last_letter = word[-1].in?(%w(x a z i v))
    bad_last_2_letters = word[-2..-1].in?(%w(ed ah ic if er wn ue ff ee ly))
    bad_last_3_letters = word[-3..-1].in?(%w(ing ism ual och uan))
    no_vowels = word.split('').none?{|l| l.in?(%w(a e i o u)) }

    !(bad_last_letter || bad_last_2_letters || bad_last_3_letters || no_vowels)
  end

  def self.to_reject?(word)
    word.in?(WORDS_TO_REJECT)
  end

end

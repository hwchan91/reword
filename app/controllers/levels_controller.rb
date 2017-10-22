class LevelsController < ApplicationController
  before_action :set_level

  def show
    @poss_words = @word.transition_words
  end

  def make_guess
    session[:"level#{params[:id]}_guesses"] << params[:chosen_word]
  end

  private
    def set_level
      @level = Level.find(params[:id])
      @history = session[:"level#{params[:id]}_history"]
      @word = (@history and @history.any?) ? Word.new(@history[-1], Dict.new('common')) : Word.new('aaaa') #Word.new(@level.start, Dict.new('common'))
    end

end

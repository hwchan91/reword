require 'pry'
class LevelsController < ApplicationController
  before_action :set_level

  def show
    if complete
      render 'complete'
    else
      render 'show'
    end
  end

  def move
    new_word = params[:word]
    history = session[:"level#{params[:id]}_history"] ||= []
    if last_word.valid_transition?(new_word, history)
      if session[:"level#{params[:id]}_history"]
        session[:"level#{params[:id]}_history"] << new_word
      else
        session[:"level#{params[:id]}_history"] = [new_word]
      end
    end
    redirect_to level_path(params[:id])
  end

  def reset
    session[:"level#{params[:id]}_history"] = nil
    redirect_to level_path(params[:id])
  end

  private
    def set_level
      @level = Level.find(params[:id])
      if session[:"level#{params[:id]}_history"].is_a? Array
        @history = session[:"level#{params[:id]}_history"]
      else
        @history = session[:"level#{params[:id]}_history"] = [@level.start]
      end
      @word = last_word
      @choices = @word.choices(@history)

    end

    def last_word
      (@history and @history.any?) ? Word.new(@history[-1], Dict.new('common')) : Word.new(@level.start, Dict.new('common'))
    end

    def complete
      @level.target == @word.word
    end


  

end

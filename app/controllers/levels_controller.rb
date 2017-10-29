class LevelsController < ApplicationController
  before_action :set_level, only: [:show, :move]
  before_action :get_word, only: [:show]

  def show
    if complete
      render 'complete'
    else
      render 'show'
    end
  end

  def move
    new_word = params[:word]
    history = session[:"level#{params[:id]}_history"] ||= [] #empty array is necc for valid_transition method
    if last_word.valid_transition?(new_word, history)
      if session[:"level#{params[:id]}_history"]
        session[:"level#{params[:id]}_history"] << {word: new_word, changed_index: params[:changed_index]} #new_word
      else
        session[:"level#{params[:id]}_history"] = [ {word: new_word, changed_index: params[:changed_index]} ] #[new_word]
      end
    end
    redirect_to level_path(params[:id])
  end

  def reset
    session[:"level#{params[:id]}_history"] = nil
    redirect_to level_path(params[:id])
  end

  def undo
    undo_to_index = -(params[:steps].to_i + 1)
    history = session[:"level#{params[:id]}_history"]
    session[:"level#{params[:id]}_history"] = history[0..undo_to_index] unless history.length <= 1
    #redirect_to level_path(params[:id])
    set_level
    get_word
    @undo = "true"
    render 'show'
  end

  private
    def set_level
      @level = Level.find(params[:id])
      if session[:"level#{params[:id]}_history"].is_a? Array
        @history = session[:"level#{params[:id]}_history"]
      else
        @history = session[:"level#{params[:id]}_history"] = [ {"word" => @level.start, "changed_index" => nil } ]
      end
    end

    def get_word
      @word = last_word
      @choices = @word.choices(@history.map{|hash| hash["word"]})
      @definition = Rails.cache.fetch("define_#{@word.word}"){ @word.get_definition }
    end

    def last_word
      (@history and @history.any?) ? Word.new(@history[-1]["word"], Dict.new('common')) : Word.new(@level.start, Dict.new('common'))
    end

    def complete
      @level.target == @word.word
    end


  

end

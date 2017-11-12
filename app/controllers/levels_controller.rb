class LevelsController < ApplicationController
  before_action :set_level, only: [:show, :move]
  before_action :get_word, only: [:show]

  def show
    if params[:next_level]
      session.delete(:"level#{params[:id].to_i - 1}_history")
    end

    respond_to do |format|
      format.html do 
        @complete = true if complete
        render (complete ? 'complete' : 'show')
      end
      format.js { reload_show }
    end
  end

  def move
    new_word = params[:word]
    history = session[:"level#{params[:id]}_history"] ||= [] #empty array is necc for valid_transition method
    if last_word.valid_transition?(new_word, history)
      if session[:"level#{params[:id]}_history"]
        session[:"level#{params[:id]}_history"] << word_hash 
      else
        session[:"level#{params[:id]}_history"] = [word_hash]
      end
    end
    reload_show
  end

  def reset
    session[:"level#{params[:id]}_history"] = nil
    reload_show
  end

  def undo
    undo_to_index = -(params[:steps].to_i + 1)
    history = session[:"level#{params[:id]}_history"]
    session[:"level#{params[:id]}_history"] = history[0..undo_to_index] unless history.length <= 1

    @undo = true
    reload_show
  end

  def index
    @levels = Level.all
  end

  private
    def set_level
      @level = Level.find(params[:id])
      @limit = @level.limit ||= @level.path.length + 2
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

    def reload_show
      set_level
      get_word
      if complete
        @complete = true
        render 'complete.js'
      else
        render 'reload_show.js'
      end
    end

    def word_hash
      {"word" => params[:word], "changed_index" => params[:changed_index]}
    end


end

class LevelsController < ApplicationController
  #before_action :check_if_hack, only: [:show, :move, :reset, :undo]
  before_action :set_level, only: [:show, :move]
  before_action :get_word, only: [:show]
  before_action :get_completed_levels, only: [:index]
  before_action :get_chapter, only: [:index]

  def show
    respond_to do |format|
      format.html do 
        if complete
          @complete = true
          update_records
          render 'complete'
        else
          render 'show'
        end
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
    @levels = Level.where(id: ((@chapter-1) * 10 + 1).. ((@chapter-1) * 10 + 10)).order(:id)
    @chapter_title = Chapter.find(@chapter).name

    respond_to do |format|
      format.html
      format.js
    end
  end

  def home
    @user = current_user
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
      @definition = @word.define
      @matches = @word.compare(@level.target)
    end

    def last_word
      (@history and @history.any?) ? Word.new(@history[-1]["word"]) : Word.new(@level.start)
    end

    def complete
      @level.target == @word.word
    end

    def reload_show
      set_level
      get_word
      if complete
        @complete = true
        update_records
        render 'complete.js'
      else
        render 'reload_show.js'
      end
    end

    def word_hash
      {"word" => params[:word], "changed_index" => params[:changed_index]}
    end

    def update_records
      level_id = params[:id]
      path = session[:"level#{level_id}_history"]
      optimal_achieved = path.length == @level.path.length
      completed_levels = current_user.completed_levels.map(&:to_i)
      optimal_levels = current_user.optimal_levels.map(&:to_i)

      unless completed_levels.any?{|id| id == @level.id }
        current_user.completed_levels << @level.id
      end

      if optimal_achieved
        unless optimal_levels.any?{|id| id == @level.id }
          current_user.optimal_levels << @level.id
        end
      end

      current_user.save!

      session.delete(:"level#{params[:id]}_history")
    end

    def get_completed_levels
      @completed_levels = current_user.completed_levels.map(&:to_i)
      @optimal_levels = current_user.optimal_levels.map(&:to_i)
    end

    def check_if_hack
      latest_level = current_user.completed_levels.order("level_id").last
      if (latest_level and params[:id].to_i > latest_level.level_id + 1 ) or (latest_level.nil? and params[:id].to_i > 1 )
        redirect_to levels_path, format: :js
      end
    end

    def get_chapter
      @curr_chapter = @completed_levels.empty? ?  1 : (@completed_levels.max / 10 ) + 1
      @chapter = params[:chapter].nil? ? @curr_chapter : params[:chapter].to_i
      # no cheating
      if params[:chapter] and (@completed_levels.empty? or (@completed_levels.max / 10) + 1 < @chapter)
        @chapter = @curr_chapter
      end
      @chapter = 5 if @chapter > 5
    end

end

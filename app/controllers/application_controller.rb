class ApplicationController < ActionController::Base
  include Evercookie::ControllerHelpers

  protect_from_forgery with: :exception
  before_action :log_in_user

  private
    def log_in_user
      binding.pry
      unless evercookie_is_set?("uid")
        new_uid = random_uid
        set_evercookie("uid", new_uid)
        User.create(uid: new_uid)
      end
    end

    def current_user
      @current_user ||= User.find_by(uid: evercookie_get_value("uid"))
    end

    def random_uid
      o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
      string = (0...50).map { o[rand(o.length)] }.join
    end
end

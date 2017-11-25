class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_cookie

  private
    def set_cookie
      unless cookies.signed[:uid]
        new_uid = random_uid
        cookies.permanent.signed[:uid] = { value: new_uid, expires: 1.hour.from_now }
      end
    end

    def current_user
      uid = cookies.signed[:uid]
      @current_user ||= User.find_or_create_by(uid: uid)
    end

    def random_uid
      o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
      string = (0...50).map { o[rand(o.length)] }.join
    end
end

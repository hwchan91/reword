class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_cookie

  private
    def set_cookie
      unless cookies.encrypted[:uid]
        new_uid = nil
        loop do
          new_uid = random_uid
          break if User.find_by(uid: new_uid).nil?
        end
        cookies.permanent.encrypted[:uid] = new_uid
      end
    end

    def current_user
      uid = cookies.encrypted[:uid]
      @current_user ||= User.find_or_create_by(uid: uid)
    end

    def random_uid
      o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
      string = (0...50).map { o[rand(o.length)] }.join
    end
end

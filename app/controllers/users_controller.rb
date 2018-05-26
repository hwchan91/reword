class UsersController < ApplicationController
  def update
    @user = current_user
    if @user.update_attributes(user_params)
      render 'update_successful.js'
    else
      render 'update_errors.js'
    end
  end

  def update_to_has_rated
    current_user.update(has_rated: true)
  end

  private
  def user_params
    params.require(:user).permit(:name, :password)
  end
end

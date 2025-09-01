class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def new
    authorize current_user
    @user = User.new
    @user.build_profile
  end

  def create
    authorize current_user
    @user = User.new(user_params)

    if @user.save
      redirect_to users_new_path, notice: 'User was successfully created.'
    else
      redirect_to users_new_path, alert: "User was not successfully created. #{@user.errors.full_messages.join(', ')}"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, profile_attributes: [:first_name, :middle_name, :last_name])
  end
end
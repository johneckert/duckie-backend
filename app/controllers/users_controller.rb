class UsersController < ApplicationController
  before_action :find_user

  def index
    users = User.all
    render json: users, status: 200
  end

  def show
    @user = user.find_by(email: user_params[:email])
    render json: @user, status: 200
  end

  def create
    @user = User.find_or_create_by(username: params[:username])
    render json: @user, status: 201
  end

  private

  def find_user
    @user = User.find_by(id: params[:id])
  end

  def user_params
    params.permit(:first_name, :last_name, :email, :password, :id)
  end

end

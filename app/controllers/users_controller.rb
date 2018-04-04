class UsersController < ApplicationController
  before_action :find_user

  def index
    users = User.all
    render json: users, status: 200
  end

  def show
    @user = user.find_by(email: params[:email])
    render json: @user, status: 200
  end

  def create
    maybe_user = User.new(first_name: params[:firstName], last_name: params[:lastName], email: params[:email], password_digest: params[:password_digest] password: params[:password] id: params[:id])
    user_check = maybe_user.save
    if user_check
      @user = User.last
      render json: @user, status: 201
    else
      render json: {'error': 'User already exists'}
    end

  end

  private

  def find_user
    @user = User.find_by(id: params[:id])
  end

  # def user_params
  #   params.permit(:first_name, :last_name, :email, :password, :id, :password_digest, :user)
  # end

end

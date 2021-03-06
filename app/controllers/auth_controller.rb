class AuthController < ApplicationController

  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      token = issue_token({ 'user_id': user.id})
      render json: {'token': token}
    else
      render json: {'error': 'Could not find or authenticate user'}
    end
  end

  def authorize
    @user = User.find_by(id: token_user_id)
    if @user
      render json: @user, serializer: UserSerializer, status: 200
    else
      render json: {'error': 'Could not find or authenticate user'}
    end
  end
end

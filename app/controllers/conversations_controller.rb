class ConversationsController < ApplicationController
  before_action :find_conversation

  def index
    conversations = Conversation.all
    render json: conversations, status: 200
  end

  def show
    render json: @conversation, status: 200
  end

  def create
    @conversation = Conversation.create(user_id: conversation_params[:user_id], transcript: conversation_params[:transcript])
    byebug
    render json: @conversation, status: 201
  end

  private

  def find_conversation
    @conversation = Conversation.find_by(id: conversation_params[:id])
  end

  def conversation_params
    params.permit(:user_id, :transcript)
  end

end

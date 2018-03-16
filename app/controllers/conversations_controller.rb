require 'rest-client'

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
    #organize for watson
    parameters = {
        'text' => @conversation.transcript,
        'features' => {
            'keywords' =>
            {
              'emotion' => false,
              'sentiment' => false
            }
          },
      'return_analyzed_text' => true
    }.to_json
    response = RestClient::Request.execute method: :post, url: "https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze?version=2017-02-27", user: ENV["watson_username"], password: ENV["watson_password"], headers: {'Content-Type': "application/json"}, payload: parameters

    puts response

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

class ConversationsController < ApplicationController
  before_action :find_user

  def index
    conversations = Conversation.all
    render json: conversations, status: 200
  end

  def show
    render json: @conversation, status: 200
  end

  def create
    @conversation = Conversation.create(audio: params[:audio])
    render json: @conversation, status: 201
  end

  private

  def find_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end

  def user_params
    params.permit(:transcript, :audio, :id)
  end

  end

end


# create_table "conversations", force: :cascade do |t|
#   t.bigint "user_id"
#   t.text "transcript"
#   t.binary "audio"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.index ["user_id"], name: "index_conversations_on_user_id"
# end

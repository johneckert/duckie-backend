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
    @conversation = Conversation.create(user_id: params[:user_id], transcript: params[:transcript])
    render json: @conversation, status: 201
  end

def update
  @conversation = Conversation.find(params[:id])
  @conversation.update(conversation_params)
  #organize for watson
  parameters = {
    'text' => @conversation.transcript,
    'features' => {
      'concepts' => {
        'limit' => 10
      },
      'keywords' =>
      {
        'emotion' => false,
        'sentiment' => false,
        'limit' => 10
      }
    }
  }.to_json

  #send transcript to watson and get keyword respons
  response = RestClient::Request.execute method: :post, url: "https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze?version=2017-02-27", user: ENV["watson_username"], password: ENV["watson_password"], headers: {'Content-Type': "application/json"}, payload: parameters

  #keyword tolerance: 1 is only words in computer_words array.  Watson retruns 0 > 1.
  tolerance = 1
  computer_words = RelevantTerms::Computer::Words
  #generate keyword objects and add to conversation
  converted_response = JSON.parse(response)

  keyword_array = create_keywords_from_keywords(converted_response, tolerance, computer_words)
  concept_array = create_keywords_from_concepts(converted_response, tolerance, computer_words)

  dirty_array = keyword_array.concat(concept_array)
  raw_array = dirty_array.uniq {|keyword| keyword[:word]}
  raw_array.sort! {|a,b| b.relevance <=> a.relevance }.first(5)

  raw_array.each do |keyword|
    keyword[:word] = keyword[:word].titleize
    current_convo_keywords = @conversation.keywords
    matching = @conversation.keywords.select{|kw| kw.word.titleize == keyword[:word]}
    if matching.length == 0
      @conversation.keywords << keyword
    end
  end

  render json: @conversation.keywords, status: 201
end


  private

  def find_conversation
    @conversation = Conversation.find_by(id: conversation_params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:user_id, :transcript, :id, :audio, :created_at, :updated_at)
  end

  #helpers for creating keyword instances
  def create_keywords_from_keywords(response_hash, tolerance, rel_word_hash)
    keyword_array = []
    response_hash['keywords'].map do |keyword_obj|
      if rel_word_hash.include?(keyword_obj['text'].downcase)
        keyword_obj['relevance'] = keyword_obj['relevance'] + 1
      end
      new_word = Keyword.create_with(relevance: keyword_obj['relevance']).find_or_create_by(word: "#{keyword_obj['text']}")
      if new_word[:relevance] >= tolerance
        keyword_array << new_word
      end
    end
    keyword_array
  end

  def create_keywords_from_concepts(response_hash, tolerance, rel_word_hash)
    keyword_array = []
    response_hash['concepts'].map do |concept_obj|
      if rel_word_hash.include?(concept_obj['text'].downcase)
        concept_obj['relevance'] = concept_obj['relevance'] + 1
      end
      new_word = Keyword.create_with(relevance: concept_obj['relevance']).find_or_create_by(word: "#{concept_obj['text']}")
      if new_word[:relevance] >= tolerance
        keyword_array << new_word
      end
    end
    keyword_array
  end
end

class KeywordsController < ApplicationController

  ### For Testing Access Only
  def index
    keywords = Keyword.all
    render json: keywords, status: 200
  end

  private

  def find_keyword
    @keyword = Keyword.find_by(id: conversation_params[:id])
  end

  def keyword_params
    params.permit(:word, :relevance)
  end

end

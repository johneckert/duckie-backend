class Conversation < ApplicationRecord
  belongs_to :user
  has_many :conversation_keywords
  has_many :keywords, through: :conversation_keywords

end

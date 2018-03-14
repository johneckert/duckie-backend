class Keyword < ApplicationRecord
  has_many :conversation_keywords
  has_many :conversations, through: :conversation_keywords
end

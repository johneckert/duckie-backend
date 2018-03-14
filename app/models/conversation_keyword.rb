class ConversationKeyword < ApplicationRecord
  belongs_to :conversation
  belongs_to :keyword
end

class User < ApplicationRecord
  has_many :conversations
  has_secure_password


  def number_of_conversations
    self.conversations.length
  end
end

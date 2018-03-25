class User < ApplicationRecord
  has_many :conversations
  has_secure_password


  def number_of_conversations
    self.conversations.length
  end

  def user_keywords
    all_users_keywords =[]

    self.conversations.each do |convo|
      convo.keywords.each do |keyword|
        all_users_keywords << keyword
      end
    end
    no_duplicates = all_users_keywords.uniq {|k| k.word}
    no_duplicates.sort! {|a,b| b.relevance <=> a.relevance}
    top_ten = no_duplicates[0 .. 11]
  end
end

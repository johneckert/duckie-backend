class CreateConversationKeywords < ActiveRecord::Migration[5.1]
  def change
    create_table :conversation_keywords do |t|
      t.references :conversation, foreign_key: true
      t.references :keyword, foreign_key: true

      t.timestamps
    end
  end
end

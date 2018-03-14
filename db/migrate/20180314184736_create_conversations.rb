class CreateConversations < ActiveRecord::Migration[5.1]
  def change
    create_table :conversations do |t|
      t.references :user, foreign_key: true
      t.text :transcript
      t.binary :audio

      t.timestamps
    end
  end
end

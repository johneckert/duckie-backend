class CreateKeywords < ActiveRecord::Migration[5.1]
  def change
    create_table :keywords do |t|
      t.text :word
      t.float :relevance

      t.timestamps
    end
  end
end

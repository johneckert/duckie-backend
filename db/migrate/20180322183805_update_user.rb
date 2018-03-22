class UpdateUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :first_name, :text
    add_column :users, :last_name, :text
    add_column :users, :email, :text
    add_column :users, :password_digest, :text
    remove_column :users, :username, :text
  end
end

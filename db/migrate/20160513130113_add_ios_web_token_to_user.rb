class AddIosWebTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :web_token_ios, :string
  end
end

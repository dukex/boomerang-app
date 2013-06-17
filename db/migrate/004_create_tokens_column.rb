class CreateTokensColumn < ActiveRecord::Migration
  def change
    add_column :authors, :facebook_access_token, :string
    add_column :authors, :twitter_oauth_token, :string
    add_column :authors, :twitter_token_secret, :string
  end
end

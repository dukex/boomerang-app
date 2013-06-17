class CreateAuthor < ActiveRecord::Migration
  def change
    create_table "authors" do |t|
      t.string "atom_url"

    #   t.integer  "resource_server_id",               :null => false
    #   t.string   "access_token",       :limit => 40, :null => false
    #   t.string   "refresh_token",      :limit => 40, :null => false
    #   t.string   "uid",                :limit => 40, :null => false
    #   t.datetime "expires_at"
    #   t.datetime "created_at"
    #   t.datetime "updated_at"
      t.timestamp
    end
  end
end

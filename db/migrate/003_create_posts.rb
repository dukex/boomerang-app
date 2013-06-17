class CreatePosts < ActiveRecord::Migration
  def change
    create_table "posts" do |t|
      t.string "uid"
      t.text "content"
      t.boolean "was_shared", default: false
      t.integer "author_id"
      t.timestamp
    end
  end
end

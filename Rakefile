require "rubygems"
require "bundler/setup"

require 'pg'
require 'active_record'


namespace :db do
  desc "Create the db"
  task :create do
    db = URI.parse(ENV['DATABASE_URL'] || "postgres://localhost:5432/diaspora_dev")

    ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :port     => db.port,
      :username => db.user,
      :password => db.password,
      :database => "postgres",
      :encoding => 'utf8',
      :schema_search_path => "public"
    )

    ActiveRecord::Base.connection.create_database(db.path[1..-1])
  end

  task :migrate do
    require "./config/boot"
    ActiveRecord::Migrator.migrate("db/migrate/")
  end
end

desc "Task description"
task :updater do
  require "./config/boot"
  require "models/author"
  require "models/post"

  Author.all.each do |author|
    facebook = Koala::Facebook::API.new(author.facebook_access_token) if author.facebook_access_token
    twitter = false
    #twitter = Twitter::Client.new(
    #  :oauth_token => "",#author.twitter_oauth_token,
    #  :oauth_token_secret => ""#author.twitter_token_secret
    #)

    atom = Proudhon::Atom.from_uri(author.atom_url)
    atom.entries.each do |entry|
      attributes = {uid: entry.id, content: entry.content, author_id: author.id}
      post = Post.where(attributes).first_or_create

      next if post.was_shared?
      begin
        link_count = entry.links[:alternate].size
        message = "#{entry.content[0, (130-link_count)]}...\n entry.links[:alternate]"
        facebook.api("/me/feed", {message: message}, "post") if facebook
        twitter.update(message[0, 139]) if twitter
        if facebook or twitter
          post.update_attribute :was_shared, true
        end
      rescue => e
        puts e
        post.update_attribute :was_shared, false
      end
    end
  end
end

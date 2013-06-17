require "rubygems"
require "bundler/setup"

require 'pg'
require 'active_record'
require 'yaml'

namespace :db do
  desc "Create the db"
  task :create do
    dbconfig = YAML::load(File.open(File.expand_path("../config/database.yml", __FILE__)))[ENV.fetch("RACK_ENV", 'development')]

    admin_connection = dbconfig.merge({'database'=> 'postgres',
      'schema_search_path'=> 'public'})
    ActiveRecord::Base.establish_connection(admin_connection)
    ActiveRecord::Base.connection.create_database(dbconfig.fetch('database'))
  end

  task :migrate do
    dbconfig = YAML::load(File.open(File.expand_path("../config/database.yml", __FILE__)))[ENV.fetch("RACK_ENV", 'development')]
    ActiveRecord::Base.establish_connection(dbconfig)
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
        message = "#{entry.links[:alternate]} #{entry.content}"

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

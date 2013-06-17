require 'active_record'
require 'uri'

db = URI.parse(ENV['DATABASE_URL'] || "postgres://localhost:5432/diaspora_dev")

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :port     => db.port,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'
)

ActiveRecord::Base.logger = Logger.new(STDERR)

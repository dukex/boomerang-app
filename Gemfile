source 'https://rubygems.org'

gem "sinatra", "~> 1.3"
gem "mustache", "~> 0.99", require: "mustache/sinatra"
gem "diaspora-client", github: "diaspora/diaspora-client"
gem "rake"

group :development, :test do
  gem "awesome_print"
  gem "pry"
  gem "racksh"
end

group :test do
  gem "rspec", "~> 2.7"
  gem "rack-test", "~> 0.6", require: "rack/test"
end

require 'active_record'
require 'yaml'

dbconfig = YAML::load(File.open(File.expand_path("../database.yml", __FILE__)))[ENV.fetch("RACK_ENV", 'development')]

ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(STDERR)

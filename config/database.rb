require 'active_record'
require 'yaml'
require 'erb'

database_file = File.open(File.expand_path("../config/database.yml", __FILE__))
dbconfig = YAML::load(ERB.new(database_file).result)[ENV.fetch("RACK_ENV", 'development')]


ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(STDERR)

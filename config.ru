require File.expand_path("../app", __FILE__)

use Rack::Session::Cookie, secret: "23123asdak234h2k4jh2342"
run Sinatra::Application

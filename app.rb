require "./config/boot"

class BoomerangApp < Sinatra::Base
  register Sinatra::Warden

  get "/" do
    mustache "index"
  end
end


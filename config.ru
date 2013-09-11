require "rubygems"
require "bundler"

Bundler.require

path = File.expand_path "../", __FILE__
require "#{path}/chatlog.rb"

set :environment, :production
set :run, false
run Sinatra::Application

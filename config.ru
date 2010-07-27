require 'rubygems'
require 'sinatra'

set :run, false
set :env, :development

require 'ttt'

run Sinatra::Application
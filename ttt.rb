require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'logger'
require 'haml'

## Configuration
configure :development do
	DataMapper.setup(:default, 'sqlite::ttt')
	DataMapper::Logger.new(STDOUT, :debug)
end

configure :production do
	DataMapper.setup(:default, 'sqlite::memory:')
end

## Models
class Tape
	include DataMapper::Resource
	property :id,					Serial
	property :title,			String
	property :created_at,	DateTime
	
	validates_presence_of :title
end

## Controller Actions

titlePrefix = 'tapestapestapes'

# index
get '/' do
	@tapes=Tape.all :order=>[:created_at]
	@pageTitle = titlePrefix
	haml :index
end

# create tape
post '/new/tape' do
	tape=Tape.create(:title=>params[:title],:created_at=>Time.now)
	redirect '/'
end

get '/new/tape' do
	@pageTitle = titlePrefix + ' - new tape'
	haml :newTape
end
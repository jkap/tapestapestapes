require 'rubygems'
require 'sinatra'
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

# index

get '/' do
	@tapes=Tape.all :order=>[:created_at]
	haml :index
end

# create tape
post '/' do
	tape=Tape.create(:title=>params[:title],:created_at=>Time.now)
	redirect '/'
end
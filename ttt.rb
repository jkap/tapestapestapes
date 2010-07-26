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
	DataMapper.setup(:default, 'sqlite::ttt')
end

## Models
class Tape
	include DataMapper::Resource
	property :id,					Serial
	property :title,			String
	property :created_at,	DateTime
	
	validates_presence_of :title
	
	has n, :songs, :through => Resource
end

class Song
	include DataMapper::Resource
	property :id,					Serial
	property :title,			String
	property :artist,			String
	property :created_at,	DateTime
	
	validates_presence_of :title
	validates_presence_of :artist
	
	has n, :tapes, :through => Resource
end

DataMapper.finalize
DataMapper.auto_upgrade!

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

# create song
post '/new/song' do
	song=Song.create(:title=>params[:title],:artist=>params[:artist],:created_at=>Time.now)
	redirect '/'
end

get '/new/song' do
	@pageTitle = titlePrefix + ' - new song'
	haml :newSong
end

# view songs
get '/view/songs' do
	@songs=Song.all :order=>[:created_at]
	@pageTitle = titlePrefix + ' - all the songs'
	haml :viewSongs
end

get '/view/song/:id' do
	@song=Song.get(params[:id])
	@tapes=@song.tapes
	@songInfo = @song.title + ' by ' + @song.artist
	@pageTitle = titlePrefix + ' - ' + @songInfo
	haml :viewSong
end

# view tapes
get '/view/tape/:id' do
	@tape=Tape.get(params[:id])
	@songs=@tape.songs
	@pageTitle = titlePrefix + ' - ' + @tape.title
	haml :viewTape
end

# add song to tape
post '/add/song' do
	song=Song.get(params[:songID])
	tape=Tape.get(params[:tapeID])
	tape.songs << song
	tape.save
	redirect '/view/tape/' + params[:tapeID]
end
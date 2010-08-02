require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'dm-core'
require 'dm-validations'
require 'dm-migrations'
require 'logger'
require 'haml'
require 'dm-serializer/to_json'
require 'fileutils'

## Configuration
configure :development do
	DataMapper.setup(:default, 'sqlite::ttt')
	DataMapper::Logger.new(STDOUT, :debug)
end

configure :production do
	DataMapper.setup(:default, ENV['DATABASE_URL'])
end

## Models
class Tape
	include DataMapper::Resource
	property :id,					Serial
	property :title,			String
	property :created_at,	DateTime
	
	validates_presence_of :title
	
	has n, :songs, :through => Resource
	belongs_to :user
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

class User
	include DataMapper::Resource
	property :id,					Serial
	property :email, 			String, :length => (5..40), :unique => true, :format => :email_address
	property :uname,			String, :unique => true
	property :created_at,	DateTime
	
	has n, :tapes
	
	validates_presence_of :email
	validates_presence_of :uname
end

DataMapper.finalize
DataMapper.auto_upgrade!

## Controller Actions

titlePrefix = 'tapestapestapes'
musicDirectory = FileUtils.pwd() + '/public/static/music'

# index
get '/' do
	@tapes=Tape.all :order=>[:created_at]
	@pageTitle = titlePrefix
	haml :index
end

# create tape
post '/new/tape' do
	tape=Tape.new(:title=>params[:title],:created_at=>Time.now)
	tape.user=User.first(:uname => params[:uname])
	tape.save
	redirect '/'
end

get '/new/tape' do
	@pageTitle = titlePrefix + ' - new tape'
	haml :newTape
end

# create song
post '/new/song' do
	song=Song.create(:title=>params[:title],:artist=>params[:artist],:created_at=>Time.now)
	uploadData = params[:upload_data][:tempfile]
	path = File.join(musicDirectory, song.id.to_s() + '.mp3')
	File.open(path, "wb") { |f| f.write(uploadData.read) }
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

get '/view/tape/:id/json' do
	@tape=Tape.get(params[:id])
	@tape.songs.to_json
end

# add song to tape
post '/add/song' do
	song=Song.get(params[:songID])
	tape=Tape.get(params[:tapeID])
	tape.songs << song
	tape.save
	redirect '/view/tape/' + params[:tapeID]
end

get '/add/song' do
	@pageTitle = titlePrefix + ' - add song to tape'
	haml :addSong
end

# create user
post '/new/user' do
	user=User.create(:email=>params[:email], :uname=>params[:uname],:created_at=>Time.now)
	redirect '/'
end

# view users
get '/user/:uname' do
	@user=User.first(:uname => params[:uname])
	@pageTitle = titlePrefix + ' - ' + @user.uname + '\'s profile'
	haml :viewUser
end

# view artist
get '/view/artist/:artistName' do
	@songs=Song.all(:artist => params[:artistName])
	@pageTitle = titlePrefix + ' - ' + params[:artistName]
	haml :viewArtist
end
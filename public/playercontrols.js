// Handles niftyplayer playlist functions
// written by Josh Kaplan in 2010

// creates a new player object
function Player(tapeId, playerName) {
	this.tapeId = tapeId;
	this.playerName = playerName;
	var playlist = [];
	$.ajax({
		url:'/view/tape/'+ this.tapeId.toString() +'/json',
		async: false,
		dataType: 'json',
		success: function (json) {
			playlist = json;
		}
	});
	this.playlist = playlist;
	this.numSongs = playlist.length;
	this.isPlaying = false;
	this.songLoaded = -1;
	
	this.playPause = function() {
		this.register();
		// not playing
		if(this.isPlaying == false) {
			// nothing loaded
			if(this.songLoaded == -1) {
				// load and play first song
				this.songLoaded = 0;
				niftyplayer(this.playerName).loadAndPlay('/static/music/' + this.playlist[this.songLoaded].id.toString() + '.mp3');
				this.updateNowPlaying(false);
				return 'loaded';
			// it's paused
			} else {
				// unpause
				niftyplayer(this.playerName).play();
				this.isPlaying = true;
				this.updateNowPlaying(false);
				return 'play';
			}
		// it's playing
		} else {
			// pause
			niftyplayer(this.playerName).pause();
			this.isPlaying = false;
			this.updateNowPlaying(true);
			return 'pause';
		}
		return 'nothing happened';
	}
	
	this.nextSong = function() {
		if(this.songLoaded == this.numSongs - 1) {
			return 'last song in list';
		}
		this.songLoaded++;
		niftyplayer(this.playerName).loadAndPlay('/static/music/' + this.playlist[this.songLoaded].id.toString() + '.mp3');
		this.updateNowPlaying(false);
	}
	
	this.prevSong = function() {
		if(this.songLoaded == 0) {
			return 'first song in list';
		}
		this.songLoaded--;
		niftyplayer(this.playerName).loadAndPlay('/static/music/' + this.playlist[this.songLoaded].id.toString() + '.mp3');
		this.updateNowPlaying(false);
	}
	
	this.finished = function() {
		this.nextSong();
	}
	
	this.register = function() {
		javascript:niftyplayer('niftyPlayer1').registerEvent('onSongOver', 'player.finished()')
	}
	
	this.playSong = function(index) {
		this.songLoaded = index;
		this.isPlaying = true;
		niftyplayer(this.playerName).loadAndPlay('/static/music/' + this.playlist[this.songLoaded].id.toString() + '.mp3');
		this.updateNowPlaying(false);
		return 'loaded';
	}
	
	this.updateNowPlaying = function(paused) {
		if(paused == true) {
			document.title = 'tapestapestapes: ' + this.playlist[this.songLoaded].title + ' by ' + this.playlist[this.songLoaded].artist + ' (paused)';
			document.getElementById('nowPlayingInfo').innerHTML = this.playlist[this.songLoaded].title + ' by ' + this.playlist[this.songLoaded].artist + ' (paused)';
		} else {
			document.getElementById('nowPlayingInfo').innerHTML = this.playlist[this.songLoaded].title + ' by ' + this.playlist[this.songLoaded].artist;
			document.title = 'tapestapestapes: ' + this.playlist[this.songLoaded].title + ' by ' + this.playlist[this.songLoaded].artist;
		}
	}
	
	this.updateTime = function(time) {
		document.getElementById('nowPlayingTime').innerHTML = '| ' + time;
	}
	
	this.updateLoad = function(load) {
		var newLoad = load * 100;
		newLoad = Math.round(newLoad);
		newLoad = newLoad + '%';
		if(load != 1) {
			document.getElementById('nowPlayingLoad').innerHTML = '| ' + newLoad;
		}
		else {
			document.getElementById('nowPlayingLoad').innerHTML = '';
		}
	}
	
	return this;
}


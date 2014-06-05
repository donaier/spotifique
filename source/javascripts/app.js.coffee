#= require vendor/modernizr
#= require vendor/jquery
#= require vendor/jquery.cookie
#= require vendor/fastclick
#= require vendor/placeholder

#= require vendor/foundation
#= require vendor/foundation.slider
#= require vendor/foundation.offcanvas

#= require_tree .

$ ->
  # UI STUFF

  $(document).foundation()

  $('footer').on 'click', '#scroll-controls', ->
    $('footer').toggleClass('shifted')

  # MOPIDY + MUSIC STUFF

  consoleError = console.error.bind(console)

  # UNUSED SO FAR
  trackDesc = (track) ->
    track.name + " by " + track.artists[0].name + " from " + track.album.name

  # lil functions
  stripUserId = (name) ->
    name.split(RegExp(" by "))[0]

  getFirst = (list) ->
    list[0]

  extractTracks = (playlist) ->
    playlist.tracks

  # PLAYLIST SETUP
  setupPlaylists = (resultArr) ->
    return  if (not resultArr) or (resultArr is "")

    child        = undefined
    label        = "<li><label>playlists</label></li>"
    tmp          = ""
    starredRegex = /spotify:user:.*:starred/g
    starred      = undefined
    i = 0

    while i < resultArr.length
      # Check if this is Spotify's "Starred" playlist
      if starredRegex.test(resultArr[i].uri)
        starred = "<li><a href=\"#\" data-pluri=\"" + resultArr[i].uri + "\"\">&#9733; Starred Tracks</a></li>"
      else
        child = "<li><a href=\"#\" data-pluri=\"" + resultArr[i].uri + "\"\">" + stripUserId(resultArr[i].name) + "</a></li>"
        tmp += child
      i++

    tmp = label + starred + tmp  if starred
    # $("#playlistslist").empty()
    $("#playlistslist").html tmp
    return

  listPlaylists = ->
    mopidy.playlists.getPlaylists(false).then setupPlaylists, console.error
    return

  processPlaylistLinks = (link) ->
    mopidy.playlists.lookup($(link).attr('data-pluri'))
    .then (plist) -> printPlaylistInfo(plist, console.error)
    .then (plist) -> printPlaylistTracks(plist, console.error)

  printPlaylistInfo = (plist) ->
    plist_image = "<div class='row'><div class='columns small-4 large-2'><img src='/images/placeholder_square.png' /></div>"
    plist_info  = "<div class='columns small-8 large-10'><h5>♫ " + stripUserId(plist.name) + "</h5><p>" + plist.tracks.length + " Tracks</p></div></div>"

    $("#playlist-info").html(plist_image + plist_info)
    plist

  printPlaylistTracks = (plist) ->
    tracks_playall = "<a class='tracklist-playbutton playall button round' href='#' id='playall' data-pluri='" + plist.uri + "'>play all</a>"
    tracks_open    = "<div class='row'><div class='columns'><table id='tracktable'><thead><tr><th class='text-center' colspan='4'>" + tracks_playall + "</th></tr></thead><tbody>"
    tracks_close   = "</tbody></table></div></div>"
    tracks_actions = "<a class='tracklist-playbutton button tiny round' href='#'></a><a class='tracklist-contextbutton button tiny round' href='#'></a>"
    tracks_rows    = ""

    x = 0
    while x < plist.tracks.length
      tracks_rows += "<tr><td>" + (x+1) + ".</td><td>" + plist.tracks[x].name + "</td><td class='hide-for-small'>" + plist.tracks[x].artists[0].name + "</td><td class='actions'>" + tracks_actions + "</td></tr>"
      x++

    $("#playlist-tracks").html(tracks_open + tracks_rows + tracks_close)
    plist

  # INIT
  mopidy = new Mopidy() # Connect to server
  mopidy.on console.log.bind(console) # Log all events

  mopidy.on "state:online", ->
    listPlaylists()

    $('#playlistslist').on 'click', 'a', ->
      processPlaylistLinks(this)

    $('#playlist-tracks').on 'click', '#playall', ->
      mopidy.playlists.lookup($(this).attr('data-pluri'))
      .then(extractTracks, consoleError)
      .then(mopidy.tracklist.add, consoleError)
      .then(getFirst, consoleError)
      .then(mopidy.playback.play, consoleError)

    $('footer').on 'click', '#stopit', ->
      mopidy.playback.stop()

    $('footer').on 'click', '#playit', ->
      mopidy.playback.play()

    $('footer').on 'click', '#shuffleit', ->
      console.log 'todo'

    $('footer').on 'click', '#next', ->
      mopidy.playback.next()

    $('footer').on 'click', '#prev', ->
      mopidy.playback.previous()

    $("[data-slider]").on "change", ->
      mopidy.playback.setVolume(parseInt($(this).attr('data-slider')))

    return

#= require vendor/jquery
#= require vendor/jquery.cookie
#= require vendor/fastclick
#= require vendor/modernizr
#= require vendor/placeholder

#= require foundation.min

#= require_tree .

$ ->
  $(document).foundation()

  consoleError = console.error.bind(console)

  # UNUSED SO FAR
  trackDesc = (track) ->
    track.name + " by " + track.artists[0].name + " from " + track.album.name


  # PLAYLIST SETUP
  setupPlaylists = (resultArr) ->
    return  if (not resultArr) or (resultArr is "")

    child = undefined
    tmp = ""
    starredRegex = /spotify:user:.*:starred/g
    starred = undefined
    i = 0

    while i < resultArr.length
      # Check if this is Spotify's "Starred" playlist
      if starredRegex.test(resultArr[i].uri)
        starred = "<li><a href=\"#\" id=\"" + resultArr[i].uri + "\"\">&#9733; Starred Tracks</a></li>"
      else
        child = "<li><a href=\"#\" id=\"" + resultArr[i].uri + "\"\">" + resultArr[i].name.split(RegExp(" by "))[0] + "</a></li>"
        tmp += child
      i++

    tmp = starred + tmp  if starred
    # $("#playlistslist").empty()
    $("#playlistslist").html tmp
    return

  listPlaylists = ->
    mopidy.playlists.getPlaylists(false).then setupPlaylists, console.error
    return

  setupPlaylistLinks = (link) ->
    mopidy.playlists.lookup($(link).attr('id'))
    .then (plist) -> printPlaylistInfo(plist, console.error)
    .then (plist) -> printPlaylistTracks(plist, console.error)

  printPlaylistInfo = (plist) ->
    console.log plist.name
    plist

  printPlaylistTracks = (plist) ->
    # console.log plist.tracks.length # ok
    # console.log plist.tracks[0] # ok

    # x = 0
    # while x < plist.tracks.length
    #   console.log plist.tracks[x]
    #   x++

    # console.log plist.tracks[x] for x in [0..(plist.tracks.length-1)]

    plist

  # INIT
  mopidy = new Mopidy() # Connect to server
  mopidy.on console.log.bind(console) # Log all events

  mopidy.on "state:online", ->
    listPlaylists()

    $('#playlistslist').on 'click', 'a', ->
      setupPlaylistLinks(this)

    return

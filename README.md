## Intro

To demo how to use socketstream and redis to build an real-time auto-completer.

Usage: 
  1. redis-server
  2. socketstream new <name_of_your_project>
  3. socketstream start

## Init and WebSock session establishment

  1. server side exposes all server side function thru exports.actions object.
     when init called, websock session already created. put your init here.

> @session is the session object, has `username user_id`, `@session.setUserId data.name`.

    exports.actions =
	    init: (cb) ->
		  cb 'server inited properly'

	    search: (args, cb) ->


  2. Client side, entry into init once websock session established.
	 Put your start code there.

    exports.init = ->
      # Make a call to the server to check whether server inited properly
      SS.server.app.init (response) -> console.log 'server init status:' + response

  3. display sign in dialog, and once user signed in, bind callback to all DOM objects.


## Now you are on your own...

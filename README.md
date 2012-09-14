## Intro

To demo how to use socketstream and redis to build an real-time auto-completer.

Note that this app is based on old SocketStream @0.2.X.

Usage: 
  1. redis-server
  2. socketstream new <name_of_your_project>
  3. socketstream start

##  Redis Connection

SocketStream @0.2.x connects to Redis server by default when started.
Application can refer to Redis connection with SS attribute R.

````
    R.zadd ZKEY_COMPL, 0, prefix, (err, result) ->

    R.zrange ZKEY_COMPL, start, start+rangelen-1, (err, entries) ->

````

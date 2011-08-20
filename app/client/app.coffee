#
# Client-side Code

# Bind to events
SS.socket.on 'disconnect', ->  $('#message').text('SocketStream server is down :-(')
SS.socket.on 'connect', ->     $('#message').text('SocketStream server is up :-)')

# This method is called automatically when the websocket connection is established. 
# Do not rename/delete
exports.init = ->
    # Make a call to the server to check whether server inited properly
    SS.server.app.init (response) ->
        $('#message').text(response)
        console.log response
    bindEvent()

# 
# top level bind event to set up all View event callbacks
bindEvent = ->
    $('#search-input').click (e) ->
        SS.server.app.square 5, (result) ->
            console.log 'square='+result
        return true

    #document.getElementById('control-left').ontouchstart = (e) -> touchEvent(e, "tl", true)

    $('#search-input').keydown (e) ->
        return true if e.which not in [65..90] and e.which not in [97..122]
        console.log(e.which)
        $('#tweets').empty()
        # the event fired and reach here before search box get the event. so append keycode
        word = $('#search-input').val()
        word += String.fromCharCode(e.which)
        console.log 'searching word:'+word
        args = [word, 10]   # the RMI api only support one arg, pack into a arg list obj
        SS.server.app.search args, (results) ->
            _.each results, (tuple) ->
                console.log 'Results:'+tuple
                addTweet tuple
        return true
    return true
        
drawCanvas = ->
    return 'updating canvas'

addTweet = (tuple) ->
    e = $('<tr></tr>')  # create a DOM ele on the fly
    e.append tuple
    e.css {'border': '1px solid #aaaaaa', 'align':'center'}
    $('#tweets').append(e)
	#$('#tweets > tbody:last').after(e)

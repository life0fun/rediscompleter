# Server-side Code

completer = require('./completer')

#
# expose all server side function thru exports.actions object
#
exports.actions =
	init: (cb) ->  # this is called by SS framework after conn established!
		@session.on 'disconnect', (session) ->  # this.session is internal field 
			if session?  # existent operator, true only not undefined and null
				SS.publish.broadcast 'signedOut', session.user_id
				session.user.logout ->   # invoke the function, == f()
	
		# put your customize init stuff here.
		R.zcard 'compl', (err, card) ->
            if card <= 100
                console.log 'Bootstrapping tweet data'
                datafile = __dirname + '/../../data/tweets-short.txt'
                console.log datafile
                completer.addFromFile(datafile)
            else
                console.log 'compl keys:'+card
         cb 'server done init!'

	search: (args, callback) ->
		word = args[0]
		count = args[1]
		console.log 'client searching:'+word
		completer.search word, count, callback

	square: (number, cb) ->
		console.log('square'+number)
		cb(number*2)


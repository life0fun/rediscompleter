# Server-side Code
# all server side APIs must be published as server side actions

fs = require('fs')
_ = require('underscore')

ZKEY_COMPL = 'compl'
ZKEY_DOCS_PREFIX = 'docs:'

exports.addFromFile = addFromFile = (tweetfile) ->
	console.log 'inside addFromFile: ' + tweetfile
	fs.readFile tweetfile, (err, buf) ->
		return console.log 'error reading #{tweetfile}:'+ err if err?
		aa = buf.toString().split(/\n/)
		_.each aa, addCompletions

exports.addCompletions = addCompletions = (phrase) ->
	if phrase?
		text = phrase.trim().toLowerCase()
		console.log 'Rredis-Word:'+text

	phraseToStore = JSON.stringify phrase
	console.log 'phraseToStore:'+phraseToStore
	_.each text.split(/\s+/), (word) ->
		end_index = word.length
		i = 1
		while i<end_index
			prefix = word.slice 0, i
			console.log prefix
			R.zadd ZKEY_COMPL, 0, prefix, (err, result) ->
				console.log prefix
				console.log err if err?
			i+=1
		R.zadd ZKEY_COMPL, 0, word+'*', (err, result) ->
			console.log err if err?
		R.zadd ZKEY_DOCS_PREFIX + word, 0, phraseToStore, (err, result) ->
			console.log err if err?

# module top level search API called by client
# always do top down so you know how to break big problem.
exports.search = search = (phrase, count, callback) ->
	count = count ? 10
	callback = callback ? ->
	
	getPhraseCompletions phrase, 10, (err, completions) ->
		return callback [] if err?

		keys = _.map completions, (key) ->
			console.log key
			ZKEY_DOCS_PREFIX+key

		if keys.length
			results = {}
			iter = 0

			_.each keys, (key) ->
				console.log 'PhraseCompletion:'+key
				R.zrevrangebyscore key, 'inf', 0, 'withscores', (err, docs) ->
					return callback [] if err?
					iter++
					if docs.length > 0
						while docs.length > 0
							doc = docs.shift()  # reduce array length
							score = parseFloat(docs.shift())
							prevScore = results[doc] ? 0
							results[doc] = score + prevScore
						results[doc] += 10 * keys.length
						console.log 'results of doc:'+doc+' :'+results[doc]
					
					console.log iter, keys.length
					if iter is keys.length
						ret = []
						if not _.isEmpty results
							ret.push key for key in _.keys results
						else
							_.each keys, (k) -> ret.push(k)
						ret.sort (a,b) -> results[b] - results[a]
						_.each ret, (e) -> console.log 'ret entry:'+e
						return callback ret
		else
			callback []

# search phrase, get the full word list that contains the phrase
exports.getPhraseCompletions = getPhraseCompletions = (phrase, count, callback) ->
		  
	# when getting phrase completions, we should find a fuzzy match for the last
	# word, but treat the words before it as what the user intends.  So for
	# instance, if we get "more pie", treat that as "more* pie"
					  
	phrase = phrase.toLowerCase().trim()
	
	# tag all words but last as 'exact' matches
	phrase = phrase.replace(/(\w)\s+/g, "$1\* ")  # suffix * to all words except the last one.
	prefixes = phrase.split(/\s+/)
	resultSet = {}
	iter = 0

	_.each prefixes, (prefix) ->
		console.log('get word completion with prefix: '+prefix)
		getWordCompletions prefix, count, (err, results) ->
			return callback err, [] if err?
														 
			_.each results, (result) ->
				resultSet[result] = result
				console.log 'wordcompletion result:'+result
			iter++

			console.log 'iteration:'+iter+' prefix:'+prefixes.length
			if iter is prefixes.length
				resultList = _.map resultSet, (val, key) -> key
				console.log x for x in resultList
				callback null, resultList

# search for each individual word
# get up-to count number of completions for the given word
# if word suffix with *, get the next exact completion
exports.getWordCompletions = getWordCompletions = (word, count, callback) ->
	rangelen = 50
	prefix = word.toLowerCase().trim()
	getExact = true if word[word.length-1] is '*'
	results = []

	if not prefix
		return callback null, results

	R.zrank ZKEY_COMPL, prefix, (err, start) ->
		return callback null, results if not start
		
		# get slice from zset
		R.zrange ZKEY_COMPL, start, start+rangelen-1, (err, entries) ->
			while results.length <= count
				break if not entries or entries.length is 0

				for i in [0..entries.length-1] by 1
					entry = entries[i]
					console.log('word completion entry:'+entry)
					minlen = Math.min entry.length, prefix.length
					return callback null, results if entry.slice(0, minlen) isnt prefix.slice(0, minlen)
					# only get dict word from redis, dict word is word that ends with *
					if entry[entry.length-1] is '*' and results.length <= count
						results.push entry.slice 0, -1
						return callback null, results if getExact

			return callback null, results

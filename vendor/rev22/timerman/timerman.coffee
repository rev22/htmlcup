# Copyright (c) 2013 Michele Bini

# See MIT-LICENSE for licensing information, and the absence of a warranty

window.timerman = (win = window) ->
  { setTimeout, setInterval, clearInterval, clearTimeout } = win
  intervals = {}
  timeouts = {}
  lib =
    setTimeout: (code, delay) ->
      id = setTimeout (->
        delete timeouts[id]
        do code
      ), delay
      timeouts[id] = code
      id
    clearTimeout: (id) ->
      x = clearTimeout id
      delete timeouts[id]
      x
    setInterval: (code, delay) ->
      id = setInterval (->
        try
          do code
        catch error
          lib.clearInterval id
          throw error
      ), delay
      intervals[id] = code
      id
    clearInterval: (id) ->
      x = clearTimeout id
      delete timeouts[id]
      x
    clearAllTimeouts: -> lib.clearTimeout x for x of timeouts
    clearAllIntervals: -> lib.clearInterval x for x of intervals
    clearAll: ->
      lib.clearAllTimeouts()
      lib.clearAllIntervals()
    intervals: intervals
    timeouts: timeouts
    original: { setTimeout, setInterval, clearInterval, clearTimeout }
    install: (w = win) ->
      for x of lib.original
        w[x] = lib[x]
    uninstall: (w = win) ->
      for x of lib.original
        w[x] = lib.original[x]

  lib.install()
  lib

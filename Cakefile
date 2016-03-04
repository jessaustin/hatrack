{ exec, spawn } = require 'child_process'

command = (arg='') ->
  "coffee --watch --compile --map #{arg}"

normal = 'edit.coffee popup.coffee options.coffee'
bare = '--bare storage.coffee'

# XXX should spawn() first?
task 'watch', 'Watch coffeescript files and build them when they change.', ->
  for arg in [ normal, bare ]
    exec command(arg), (err) ->
      throw err if err

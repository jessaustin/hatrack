{ exec } = require 'child_process'
task 'build', 'Build!', ->
  exec 'coffee --watch --compile --map edit.coffee popup.coffee', (err) ->
    throw err if err
  exec 'coffee --watch --compile --map --bare storage.coffee', (err) ->
    throw err if err

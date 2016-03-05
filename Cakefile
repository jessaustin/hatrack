{ exec, spawn } = require 'child_process'
{ readdir } = require 'fs'

coffee_files = (callback) ->
  readdir '.', (err, files) ->
    unless err
      callback (file for file in files when file.endsWith '.coffee')
    else
      throw err

# don't wrap this file, since all pages include it
bare_arg = (file) ->
  if file is 'storage.coffee' then "--bare #{file} " else "#{file} "

compile_command = 'coffee --compile --map '

task 'build', 'Build coffeescript files.', ->
  coffee_files (files) ->
    for file in files
      console.log file
      exec compile_command + bare_arg file, (err) ->
        throw err if err

# XXX should spawn() first?
task 'watch', 'Watch coffeescript files and build them when they change.', ->
  coffee_files (files) ->
    for file in files
      console.log file
      exec compile_command + '--watch ' + bare_arg file, (err) ->
        throw err if err

# XXX figure out how to smoothly vary sizes for the hat(s) icons
task 'icons', 'Generate png icon files from svg files.', ->
  for icon in [ 'add', 'delete', 'edit' ]
    exec "inkscape --without-gui --file=#{icon}.svg --export-area-page
          --export-png=#{icon}.png",
      cwd: 'icons'
      (err, stdout, stderr) ->
        if err
          console.log stderr
          throw err

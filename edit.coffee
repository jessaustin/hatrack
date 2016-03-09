###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

{ i18n: { getMessage } } = chrome

# handle query params set by parent
query = {}
for pair in window.location.search.substring(1).split '&'
  [ key, val ] = pair.split '='
  query[key] = decodeURIComponent val

if query.name?
  document.querySelector '#name input'
    .setAttribute 'value', query.name

document.querySelector '#color input'
  .setAttribute 'value', query.color

for span in document.querySelectorAll 'span'
  do (span) ->
    { parentNode: { id } } = span
    unless id is 'ok'
      span.innerText = getMessage "editSpanParent#{id}"
    else
      # XXX this is not graceful
      span.innerText = getMessage "editSpanParent#{id}#{if query.index? then 'Save' else 'Add'}"

window.addEventListener 'load', ->
#  window.setTimeout ->
  console.log 'load'
#    window.close()
#  i = document.querySelector 'input'
#  i.click()
#    i.blur()
#    i.focus()
#    console.log 'of shit'
#  ,
#    2000

# close window on blur, unless the blur is due to opening a color widget
colorWidgetOpen = no

# XXX there is a bug here, because we can't figure out how to focus() on the
# window when it loads, so it doesn't close if you click on another window
# first
window.addEventListener 'blur', ->
  console.log 'blurred'
#  window.close() unless colorWidgetOpen

document.querySelector '#color input'
  .addEventListener 'click', ->
    colorWidgetOpen = yes                         # the color widget is opening

#window.addEventListener 'focus', -> # color widget is modal, so it's closed now
#  colorWidgetOpen = no

# save the (new or edited) hat
document.querySelector 'form'
  .addEventListener 'submit', (event) ->
    event.preventDefault()
    { elements: [ { value: name }, { value: color } ] } = event.target
    storage.get (items) ->
      items.splice query.index ? items.length, 1, { name, color }
      storage.set items, ->
        window.close()

# cancel button
document.querySelector '#cancel'
  .addEventListener 'click', ->
    window.close()

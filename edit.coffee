###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

{ i18n: { getMessage } } = chrome

# handle query params set by popup
query = {}
for pair in window.location.search.substring(1).split '&'
  [ key, val ] = pair.split '='
  query[key] = decodeURIComponent val

if query.name?
  document.querySelector '#name input'
    .setAttribute 'value', query.name

document.querySelector '#color input'
  .setAttribute 'value', query.color

document.querySelector 'input#tag'
  .setAttribute 'value', query.tag

for span in document.querySelectorAll 'span'
  do (span) ->
    { id } = span.parentNode
    span.innerText = getMessage "edit#{id}#{
      if id is 'ok' then (if query.index? then 'Save' else 'Add') else ''}"

# close window on blur, unless the blur is due to opening a color widget
colorWidgetOpen = no

# XXX there is a bug here, because we can't figure out how to focus() on the
# window when it loads, so it doesn't close if you click on another window
# before interacting with the form
window.addEventListener 'blur', ->
  window.close() unless colorWidgetOpen

document.querySelector '#color input'
  .addEventListener 'click', ->
    colorWidgetOpen = yes                         # the color widget is opening

window.addEventListener 'focus', -> # color widget is modal, so it's closed now
  colorWidgetOpen = no

# save the (new or edited) hat
document.querySelector 'form'
  .addEventListener 'submit', (event) ->
    event.preventDefault()
    [ { value: name }, { value: color }, { value: tag } ] = event.target.elements
    storage.getList (items) ->
      items.splice query.index ? items.length, 1, { name, color, tag }
      storage.setList items, ->
        # should we handle errors here?
        window.close()

# cancel button
document.querySelector '#cancel'
  .addEventListener 'click', ->
    window.close()

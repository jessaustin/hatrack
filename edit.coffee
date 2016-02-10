###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

# handle query params set by parent
query = {}
for pair in window.location.search.substring(1).split '&'
  [ key, val ] = pair.split '='
  query[key] = decodeURIComponent val

document.querySelector '#name'
  .setAttribute 'value', query.name if query.name?

document.querySelector '#color'
  .setAttribute 'value', query.color

document.querySelector '#add'
  .insertAdjacentHTML 'afterbegin',
      "<span>#{if query.index? then 'Save' else 'Add'}</span>"

# close window on blur, unless the blur is due to opening a color widget
colorWidgetOpen = no

window.addEventListener 'blur', ->
  window.close() unless colorWidgetOpen

document.querySelector '#color'
  .addEventListener 'click', ->     # the color widget has been opened
    colorWidgetOpen = yes

window.addEventListener 'focus', -> # color widget is modal, so it's closed now
  colorWidgetOpen = no

# save the (new or edited) hat
document.querySelector 'form'
  .addEventListener 'submit', (event) ->
    event.preventDefault()
    { elements: [ { value: name }, { value: color } ] } = event.target
    storage.get (items) ->
      items.splice query.index ? items.length, 1, { name, color }
      storage.set items, ->
        window.close()

### XXX
window.addEventListener 'load', ->
  x = 0
  x = window.setInterval ->
    if document.hasFocus()
      window.clearInterval x
    document.querySelector 'input'
      .focus()
    console.log x, document.hasFocus()
  ,
    500

Object.getOwnPropertyNames window
  .filter (key) -> key.slice(0, 2) is 'on'
  .map (key) -> key.slice 2
  .forEach (evt) ->
    console.log evt
    window.addEventListener evt, (ev) ->
      console.log ev
###

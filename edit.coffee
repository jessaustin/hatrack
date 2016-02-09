###
Copyright (c) 2016 Jess Austin <jess.austin@gmail.com>
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
  .insertAdjacentHTML 'afterbegin', "<span>#{if query.index? then 'Save Changes
    to' else 'Add'}</span>"

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
    { elements: [ { value: name }, { value: color } ] } = event.target
    chrome.storage.sync.get storageKey, (items) ->
      items = items[storageKey] ? []
      items.splice query.index ? items.length, 1, { color, name }
      chrome.storage.sync.set { storageKey: items }, ->
        window.close()
    event.preventDefault()

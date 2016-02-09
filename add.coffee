###
Copyright (c) 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

search = {}
for pair in window.location.search.substring(1).split '&'
  [ key, val ] = pair.split '='
  search[key] = decodeURIComponent val

if search.color?
  console.log search
  document.querySelector '#color'
    .setAttribute 'value', search.color

if search.name?
  document.querySelector '#name'
    .setAttribute 'value', search.name

document.querySelector '#add'
  .insertAdjacentHTML 'afterbegin', if search.index? then 'Save Changes to ' else 'Add '

# close window on blur, unless the blur is due to opening a color widget
colorWidgetOpen = no

#window.addEventListener 'blur', ->
#  unless colorWidgetOpen
#    window.close()

document.querySelector '#color'
  .addEventListener 'click', ->
    colorWidgetOpen = yes

window.addEventListener 'focus', -> # color widget is modal, so it's closed now
  colorWidgetOpen = no

# add a new hat
document.querySelector 'form'
  .addEventListener 'submit', (event) ->
    { elements: [ { value: name }, { value: color } ] } = event.target
    chrome.storage.sync.get 'cookieHats', (items) ->
      items = items.cookieHats ? []
      items.splice search.index ? items.length, 1, { color, name }
      chrome.storage.sync.set cookieHats: items, ->
        window.close()
    event.preventDefault()

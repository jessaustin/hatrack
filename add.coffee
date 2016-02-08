###
Copyright (c) 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

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
    { elements: [ { value: color }, { value: name }, _ ] } = event.target
    chrome.storage.sync.get 'cookieHats', (items) ->
      console.log 'items:', items
      items = items.cookieHats ? []
      items.push { color, name }
      chrome.storage.sync.set cookieHats: items
    event.preventDefault()

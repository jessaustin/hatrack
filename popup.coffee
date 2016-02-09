###
Copyright (c) 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

update = ->
  chrome.storage.sync.get 'cookieHats', ({ cookieHats: items }) ->
    hats = document.querySelector '#hats'
    # start with empty div
    while hats.firstChild
      hats.removeChild hats.firstChild
    for { color, name }, i in items
      do (color, name, i) ->
        hats.insertAdjacentHTML 'beforeend', "
          <div id=hat-#{i} style='background-color:#{color}'>
            <span class=hat>#{name}</span>
            <img class=delete src=icons/000106-circle-cross-mark.png />
            <img class=edit src=icons/000150-pencil.png />
          </div>"
        document.querySelector "#hat-#{i} .hat"
          .addEventListener 'click', ->
            alert "hat #{i}"
            window.close()
        document.querySelector "#hat-#{i} .delete"
          .addEventListener 'click', ->
            items.splice i, 1
            chrome.storage.sync.set cookieHats: items, update # recurse
        document.querySelector "#hat-#{i} .edit"
          .addEventListener 'click', ->
            alert "edit #{i}"

window.addEventListener 'focus', update

document.querySelector '#add'
  .addEventListener 'click', (event) ->
    chrome.windows.create
      url: 'add.html'
      type: 'popup'

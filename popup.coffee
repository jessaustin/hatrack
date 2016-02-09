###
Copyright (c) 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

update = ->
  chrome.storage.sync.get storageKey, (got) ->
    items = got[storageKey]
    hats = document.querySelector '#hats'
    # start with empty div
    while hats.firstChild
      hats.removeChild hats.firstChild
    # now fill it in
    for { color, name }, i in items
      do (color, name, i) ->
        hats.insertAdjacentHTML 'beforeend', "
          <button id=hat-#{i} style='background-color:#{color}'
              title='Open new window with this hat'>
            <span class=hat>#{name}</span>
            <img class=delete title=Delete src=icons/000106-circle-cross-mark.png />
            <img class=edit title=Edit src=icons/000150-pencil.png />
          </button>"
        document.querySelector "#hat-#{i}"
          .addEventListener 'click', ->
            alert "hat #{i}"
            window.close()
        # XXX might want to confirm before deleting?
        document.querySelector "#hat-#{i} .delete"
          .addEventListener 'click', (event) ->
            event.stopPropagation()
            items.splice i, 1
            chrome.storage.sync.set { storageKey: items }, update # recurse
        document.querySelector "#hat-#{i} .edit"
          .addEventListener 'click', (event) ->
            event.stopPropagation()
            chrome.windows.create
              url: "edit.html?color=#{encodeURIComponent color}&name=#{
                encodeURIComponent name}&index=#{i}"
              type: 'popup'
            ,
              ({tabs: [ child ] }) ->
                console.log child
    document.querySelector 'button'
      .focus()

window.addEventListener 'focus', update

document.querySelector '#add'
  .addEventListener 'click', (event) ->
    chrome.windows.create
      url: "edit.html?color=#{encodeURIComponent '#00ff00'}"
      type: 'popup'
    ,
      ({tabs: [ child ] }) ->
        console.log child

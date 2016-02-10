###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

create = (url) ->
  chrome.windows.create
    url: url
    type: 'popup'
    state: 'normal'
    focused: yes
    height: 90
    width: 700
  ,
    ({tabs: [ child ] }) ->
      console.log child

document.querySelector '#add'
  .addEventListener 'click', ->
    # XXX randomize!
    create "edit.html?color=#{encodeURIComponent '#00ff00'}"

update = ->
  storage.get (items) ->
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
            #{name}
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
            storage.set items, update # recurse
        document.querySelector "#hat-#{i} .edit"
          .addEventListener 'click', (event) ->
            event.stopPropagation()
            create "edit.html?color=#{encodeURIComponent color}&name=#{
                encodeURIComponent name}&index=#{i}"
    document.querySelector 'button'
      .focus()

window.addEventListener 'focus', update

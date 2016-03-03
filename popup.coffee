###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

# color stuff; see
# http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
PHI = ( Math.sqrt(5) - 1 ) / 2
S = 0.5
V = 0.95
P = V * (1 - S)

# generated colors will have constant saturation and value
hue2rgb = (hue) ->
  i = Math.floor hue * 6
  f = hue * 6 - i
  q = V * (1 - f * S)
  t = V * (1 - (1 - f) * S)

  [r, g, b] = switch i % 6
    when 0 then [ V, t, P ]
    when 1 then [ q, V, P ]
    when 2 then [ P, V, t ]
    when 3 then [ P, q, V ]
    when 4 then [ t, P, V ]
    when 5 then [ V, P, q ]

  hex = (c) ->
    h = Math.floor 255*c
      .toString 16
    "#{if h.length < 2 then '0' else ''}#{h}"

  '#' + (hex(c) for c in [r, g, b]).join ''

rgb2hue = (rgb) ->
  [r, g, b] = ((parseInt rgb[x..x+1], 16) / 255 for x in [1..6] by 2)
  max = Math.max r, g, b
  diff = max - Math.min r, g, b
  unless diff
    0
  else
    1/6 * switch max
      when r then (g - b) / diff + (if g < b then 6 else 0)
      when g then (b - r) / diff + 2
      when b then (r - g) / diff + 4

pickNewColor = (colors) ->
  hues = (rgb2hue color for color in colors)
    .sort (a, b) ->
      a - b
  [ begin, offset ] = (hues.map (v, i, arr) ->
      [i, (arr[i + 1] ? arr[0] + 1) - v]
    .sort ([ai, av], [bi, bv]) ->
      bv - av)[0]                      # backwards so the maximum will be first
  offset = 1 unless offset
  hue2rgb hues[begin] + PHI * offset


create = (url, x, y) ->
  chrome.windows.create
    url: url
    type: 'popup'
    state: 'normal'
#    focused: no
    height: 90
    width: 700
    left: x
    top: y
#  ,
#    ({tabs: [ { windowId } ] }) ->
#      chrome.windows.update windowId, drawAttention: yes

document.querySelector '#add'
  .addEventListener 'click', ({screenX, screenY}) ->
    storage.get (items) ->
      create "edit.html?color=#{encodeURIComponent pickNewColor (
          color for {color} in items)}", screenX, screenY

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
            <div>
              <img class=edit title=Edit src=icons/edit.png />
              <img class=delete title=Delete src=icons/delete.png />
            </div>
          </button>"
        document.querySelector "#hat-#{i}"
          .addEventListener 'click', ->
            alert "hat #{i}"
            window.close()
        document.querySelector "#hat-#{i} .edit"
          .addEventListener 'click', (event) ->
            event.stopPropagation()     # don't let the button see this event
            create "edit.html?index=#{i}&color=#{
                encodeURIComponent color}&name=#{
                encodeURIComponent name}", event.screenX, event.screenY
        # XXX might want to confirm before deleting?
        document.querySelector "#hat-#{i} .delete"
          .addEventListener 'click', (event) ->
            event.stopPropagation()
            items.splice i, 1
            storage.set items, update # recurse
    document.querySelector 'button'
      .focus()

storage.get (items) ->
  if items.length
    window.addEventListener 'focus', update
  else
    storage.set [ name: 'My First Hat', color: hue2rgb Math.random() ], ->
      window.addEventListener 'focus', update
      update()

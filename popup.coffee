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

hex = (c) ->
  h = c.toString 16
  "#{if h.length < 2 then '0' else ''}#{h}"

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
  '#' + (hex(Math.floor 255 * c) for c in [r, g, b]).join ''

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

bg2rgb = (bg) ->
  [ _, r, g, b ] = bg.split /(?:rgb\()|(?:, )|\)/
  '#' + (hex(parseInt c) for c in [r, g, b]).join ''

# use of golden ratio inspired by
# //martin.ankerl.com/2009/12/09/how-to-create-random-colors-programmatically/
# this is a bit more complicated than that case, since rather than generating
# all colors at once, we're reacting to user color edits as well
pickNewColor = (colors) ->
  hues = (rgb2hue color for color in colors)
    .sort (a, b) ->
      a - b
  [ begin, offset ] = (hues.map (v, i) ->
      [i, (hues[i + 1] ? hues[0] + 1) - v]
    .sort ([ai, av], [bi, bv]) ->
      bv - av)[0]                 # sort backwards so the maximum will be first
  offset = 1 unless offset        # correction for the single-hue case
  hue2rgb hues[begin] + PHI * offset

# regular gui stuff
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

# don't frighten the user with a blank menu
storage.get (items) ->
  unless items.length
    storage.set [ name: 'My First Hat', color: hue2rgb Math.random() ], ->
      update()

# script-global list, written by update(), read by everyone
items = []

update = ->
  storage.get (gotten) ->
    items = gotten
    hats = document.querySelector '#hats'
    # start with empty div
    while hats.firstChild
      hats.removeChild hats.firstChild
    # now fill it in
    for { color, name }, i in items
      do (color, name, i) ->
        hats.insertAdjacentHTML 'beforeend', "
          <button id=hat-#{i} class=open style='background-color:#{color}'
              draggable=true title='Open new window with this hat'>
            <span>#{name}</span>
            <div>
              <img class=edit title=Edit src=icons/edit.png />
              <img class=delete title=Delete src=icons/delete.png />
            </div>
          </button>"
    document.querySelector 'button'
      .focus()

# has to be window; not sure why
window.addEventListener 'focus', update

document.addEventListener 'click',
  ({screenX, screenY, target: {className, id, parentNode: {parentNode}}}) ->
    if className is 'open'
      # XXX drag and drop!
      [ ..., id ] = id.split '-'
      alert "hat #{id}"
      window.close()
    else
      { id, style } = parentNode
      [ ..., id ] = id.split '-'
      id = parseInt id
      if className is 'delete'
        # XXX might want to confirm before deleting?
        items.splice id, 1
        storage.set items, update
      else if className is 'edit'
        create "edit.html?index=#{id}&color=#{
            encodeURIComponent bg2rgb style.backgroundColor}&name=#{
            encodeURIComponent parentNode.querySelector('span').innerText}",
          screenX, screenY

document.querySelector '#add'
  .addEventListener 'click', ({screenX, screenY}) ->
    create "edit.html?color=#{encodeURIComponent pickNewColor (
        color for {color} in items)}", screenX, screenY

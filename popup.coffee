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
  '#' + (hex Math.floor 255 * c for c in [r, g, b]).join ''

rgb2hue = (rgb) ->
  [r, g, b] = (parseInt(rgb[x..x+1], 16) / 255 for x in [1..6] by 2)
  max = Math.max r, g, b
  diff = max - Math.min r, g, b
  unless diff
    0
  else
    1/6 * switch max
      when r then (g - b) / diff + (if g < b then 6 else 0)
      when g then (b - r) / diff + 2
      when b then (r - g) / diff + 4

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
edit = ({ color, index, name, tag, x, y }) ->
  chrome.windows.create
    url: "edit.html?#{("#{k}=#{encodeURIComponent v}" for k, v of {
      color, index, name, tag } when v?).join '&'}"
    type: 'popup'
    state: 'normal'
    height: 86
    width: 802
    left: x
    top: y
    focused: yes

# L10n
{ getMessage } = chrome.i18n

document.querySelector '#add'
  .title = getMessage 'popAddHat'

document.querySelector '#add span'
  .insertAdjacentHTML 'beforeend', getMessage 'popAddHat'

# don't frighten the user with a blank menu
storage.getList (items) ->
  unless items.length
    hat =
      color: hue2rgb Math.random()
      name: getMessage 'popEmptyDefaultHat'
      tag: (Math.random() * Math.pow 2, 32).toString 16
    storage.setList [ hat ], update

# script-global list, written by update(), read by everyone
items = []

update = ->
  storage.getList (gotten) ->
    items = gotten
    hats = document.querySelector '#hats'
    # start with empty div
    while hats.firstChild
      hats.removeChild hats.firstChild
    # now fill it in
    for { color, name }, i in items
      do (color, name, i) ->
        hats.insertAdjacentHTML 'beforeend', "
          <button id=hat-#{i} class=hat style='background-color:#{color}'
              draggable=true title='#{getMessage 'popHatOpenWindow'}'>
            <span>#{name}</span>
            <div>
              <img class=edit title='#{getMessage 'popHatEdit'}'
                src=icons/edit.png />
              <img class=delete title='#{getMessage 'popHatDelete'}'
                src=icons/delete.png />
            </div>
          </button>"
    document.querySelector 'button'
      .focus()

# has to be window; not sure why
window.addEventListener 'focus', update

document.addEventListener 'click', ({ target, screenX, screenY }) ->
  { className } = target
  if className is 'hat'
    [ ..., index ] = target.id.split '-'
    alert "hat #{index}"
    window.close()
  else
    { id } = target.parentNode.parentNode ? {}
    [ ..., index ] = id?.split? '-'
    index = parseInt index
    { color, name, tag } = items[index] ? {}
    if className is 'edit'
      [ x, y ] = [ screenX, screenY ]
      edit { color, index, name, tag, x, y }
    else if className is 'delete'
      target.parentNode.insertAdjacentHTML 'beforeend', "
        <div id=really>
          <label>#{getMessage 'popReallyDelete'}
            <button id=not-really autofocus>#{
              getMessage 'popReallyDeleteNo'}</button>
            <button id=yes-really>#{getMessage 'popReallyDeleteYes'}</button>
          </label>
        </div>"
      really = target.parentNode.querySelector '#really'
      really.addEventListener 'blur', ->
        really.remove()
      really.querySelector '#not-really'
        .addEventListener 'click', ->
          really.remove()
      really.querySelector '#yes-really'
        .addEventListener 'click', ->
          items.splice index, 1
          really.remove()
          storage.setList items, ->
            storage.removeCache tag ? '', update

# open the edit window to make a new hat
document.querySelector '#add'
  .addEventListener 'click', ({ screenX, screenY }) ->
    edit
      color: pickNewColor (color for {color} in items)
      tag: (Math.random() * Math.pow 2, 32).toString 16
      x: screenX
      y: screenY

# drag and drop
dragging = null

document.addEventListener 'dragstart', ({ dataTransfer, target }) ->
  target.classList.add 'dragging'      # it seems this never has to be removed?
  [ ..., index ] = target.id.split '-'
  dragging = target
  dataTransfer.effectAllowed = 'move'
  dataTransfer.setData 'text/plain', index

document.addEventListener 'dragenter', ({ target: { classList }}) ->
  classList.add 'over'

document.addEventListener 'dragleave', ({ target: { classList }}) ->
  classList.remove 'over'

document.addEventListener 'dragover', (event) ->
  event.preventDefault()
  event.dataTransfer.dropEffect = 'move'

document.addEventListener 'drop', ({ dataTransfer, target }) ->
  unless target is dragging
    [ ..., index ] = target.id.split '-'
    [ moved ] = items.splice dataTransfer.getData('text/plain'), 1
    items.splice index, 0, moved
    storage.setList items, update
  dragging = null

document.addEventListener 'dragend', ({ target: { classList }}) ->
  classList.remove? 'dragging', 'over'

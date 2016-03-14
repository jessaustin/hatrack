###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

{ getMessage } = chrome.i18n

# handle query params set by popup
query = {}
for pair in window.location.search.substring(1).split '&'
  [ key, val ] = pair.split '='
  query[key] = decodeURIComponent val

titleString = "#{getMessage 'extName'} ::
    #{getMessage if query.index? then 'editTitle' else 'editAddTitle'} "
setTitle = (name) ->
  document.title = titleString + if name?.length then ":: #{name}" else ''
setTitle query.name

input = document.querySelector '#name input'
input.setAttribute 'value', query.name ? ''
ok = document.querySelector '#ok'
input.addEventListener 'input', ({ target: { value } }) ->
  ok.removeAttribute 'disabled'
  setTitle value

document.querySelector '#color input'
  .setAttribute 'value', query.color

document.querySelector 'input#tag'
  .setAttribute 'value', query.tag

for span in document.querySelectorAll 'span'
  do (span) ->
    { id } = span.parentNode
    if id is 'ok'
      if query.index?
        id = id + 'Save'
        ok.setAttribute 'disabled', yes
        document.querySelector '#color input'
          .addEventListener 'input', ->
            ok.removeAttribute 'disabled'
      else
        id = id + 'Add'
    span.insertAdjacentHTML 'beforeend', getMessage 'edit' + id

# close window on blur, unless the blur is due to opening a color widget
colorWidgetOpen = no

# XXX there is a bug here, because we can't figure out how to focus() on the
# window when it loads, so it doesn't close if you click on another window
# before interacting with the form
window.addEventListener 'blur', ->
  window.close() unless colorWidgetOpen

document.querySelector '#color input'
  .addEventListener 'click', ->
    colorWidgetOpen = yes                         # the color widget is opening

window.addEventListener 'focus', -> # color widget is modal, so it's closed now
  colorWidgetOpen = no

# XXX is there much point to this?
#document.querySelector 'input'
#  .focus()

# save the (new or edited) hat
document.querySelector 'form'
  .addEventListener 'submit', (event) ->
    event.preventDefault()
    [{ value: name }, { value: color }, { value: tag }] = event.target.elements
    storage.getList (items) ->
      items.splice query.index ? items.length, 1, { name, color, tag }
      storage.setList items, ->
        # should we handle errors here?
        window.close()

# cancel button
document.querySelector '#cancel'
  .addEventListener 'click', ->
    window.close()

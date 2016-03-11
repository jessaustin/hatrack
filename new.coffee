###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

# handle query params set by popup
query = {}
for pair in window.location.search.substring(1).split '&'
  [ key, val ] = pair.split '='
  query[key] = decodeURIComponent val

{ getMessage } = chrome.i18n

document.body.style.backgroundColor = query.color

document.title = "#{query.name} :: #{getMessage 'extName'}"

document.querySelector 'h1'
  .insertAdjacentHTML 'beforeend', query.name

document.querySelector '#content'
  .insertAdjacentHTML 'beforeend', "<p>#{getMessage 'newContent', query.name}
      </p>"

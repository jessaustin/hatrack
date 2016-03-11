#{ getMessage } = chrome.i18n

# handle query params set by popup
query = {}
for pair in window.location.search.substring(1).split '&'
  [ key, val ] = pair.split '='
  query[key] = decodeURIComponent val

console.log window.location.search
document.body.style.backgroundColor = query.color

document.querySelector '#content'
  .insertAdjacentHTML 'beforeend', "<p>#{chrome.i18n.getMessage 'newContent',
      query.name}</p>"

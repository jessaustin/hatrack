###
Copyright (c) 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

chrome.storage.sync.get 'cookieHats', ({ cookieHats: items }) ->
  hats = document.querySelector '#hats'
  console.log items
  items.forEach ({ color, name }) ->
    hats.insertAdjacentHTML 'beforeend', "<div>#{name}</div>"

document.querySelector '#add'
  .addEventListener 'click', (event) ->
    chrome.windows.create
      url: 'add.html'
      type: 'popup'

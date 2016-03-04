###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

# this file must be transpiled with the --bare flag
storage = do ->
  storageKey = 'cookieHats'

  get = (callback) ->
    chrome.storage.sync.get storageKey, (got) ->
      callback got[storageKey] ? []

  set = (items, callback) ->
    chrome.storage.sync.set "#{storageKey}": items, callback

  {get, set}

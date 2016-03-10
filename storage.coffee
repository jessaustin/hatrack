###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

# this file must be transpiled with the --bare flag
storage = do ->
  listKey = 'hatListPleaseDontShadowThis'
  optKey = 'optionObjectPleaseDontShadowThis'

  getList = (callback) ->
    chrome.storage.sync.get listKey, (got) ->
      callback got[listKey] ? []

  setList = (items, callback) ->
    chrome.storage.sync.set "#{listKey}": items, callback

  getOpts = (callback) ->
    chrome.storage.sync.get optKey, (got) ->
      callback got[optKey] ? {}

  setOpts = (obj, callback) ->
    chrome.storage.sync.set "#{optKey}": obj, callback

  getCache = (tag, callback) ->
    chrome.storage.sync.get tag, (got) ->
      callback got[tag] ? {}

  setCache = (tag, cache, callback) ->
    chrome.storage.sync.set "#{tag}": cache, callback

  removeCache = (tag, callback) ->
    chrome.storage.sync.remove tag, callback

  {getList, setList, getOpts, setOpts, getCache, setCache, removeCache}

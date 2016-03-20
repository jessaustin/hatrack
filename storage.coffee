###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

# this file must be transpiled with the --bare flag
storage = do ->
  { local, sync } = chrome.storage

  getter = (store, key, Default=Object) ->
    (callback) ->
      store.get key, (values) ->
        callback values[key] ? new Default()

  setter = (store, key) ->
    (value, callback) ->
      store.set "#{key}": value, callback

  optKey = 'optionObjectPleaseDontShadowThis'
  listKey = 'hatListPleaseDontShadowThis'
  winKey = 'windowsObjectPleaseDontShadowThis'

  getOpts: getter sync, optKey
  setOpts: setter sync, optKey
  getList: getter sync, listKey, Array
  setList: setter sync, listKey
  getWins: getter local, winKey
  setWins: setter local, winKey

###
Copyright © 2016 Jess Austin <jess.austin@gmail.com>
Released under GNU Affero General Public License, version 3
###

{ getMessage } = chrome.i18n

document.querySelector 'h1'
  .insertAdjacentHTML 'beforeend', getMessage 'optHeading', getMessage 'extName'

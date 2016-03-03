#!/bin/sh
coffee --watch --compile --map edit.coffee popup.coffee &
coffee --watch --compile --map --bare storage.coffee &

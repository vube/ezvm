#!/bin/sh

d="$(dirname "$(readlink -f "$0")")"

export EZVM_UPDATE_DIR="$d/fixtures/update"
export EZVM_HOME_SRC="$d/fixtures/home"

exec "$(dirname $d)/bin/ezvm update" -V 100

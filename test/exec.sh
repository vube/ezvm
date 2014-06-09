#!/bin/sh

d=$(realpath $(dirname $0))

export EZVM_UPDATE_DIR="$d/fixtures/update"
export EZVM_HOME_SRC="$d/fixtures/home"

exec $(dirname $d)/bin/ezvm exec -V 100 $@

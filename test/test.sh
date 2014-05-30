#!/bin/sh

d=`dirname $0`

EZVM_UPDATE_DIR="$d/fixtures/update" $d/../bin/ezvm update -V 100

exit $?

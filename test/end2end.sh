#!/bin/sh
#
# Test that ezvm is working
#

testdir="$(dirname $0)"

export EZVM_BASE_DIR="$(dirname $("$testdir/../bin/realpath" "$testdir"))"

. "$testdir/include.sh"

d=$("$testdir/../bin/realpath" "$testdir")

export EZVM_UPDATE_DIR="$d/fixtures/update"
export EZVM_HOME_SRC="$d/fixtures/home"

cat <<END_HELO

Beginning end-to-end ezvm test.
You will see all the update fixtures get run in ascending order.
At the end you will see a success message.

==========

END_HELO

"$(dirname $d)/bin/ezvm" update $@ || exit $?

cat <<END_BYE

==========

ezvm update completed successfully.

END_BYE

#!/bin/sh
#
# Test that ezvm is working
#

testdir="$(dirname $0)"

export EZVM_BASE_DIR="$(dirname $("$testdir/../bin/realpath" "$testdir"))"

. "$testdir/include.sh"

d=$("$testdir/../bin/realpath" "$testdir")

export EZVM_LOCAL_CONTENT_DIR="$d/fixtures"

cat <<END_HELO

Beginning end-to-end ezvm test.
You will see all the update fixtures get run in ascending order.
At the end you will see a success message.

==========

END_HELO

"$(dirname $d)/bin/ezvm" update -s $@ || exit $?

# Now let's do some cleanup stuff.  It's annoying that there is a file
# in the home directory after running this test.

rm -f "$HOME/ezvm-home-dir-copy-test.txt" 2> /dev/null

cat <<END_BYE

==========

ezvm update completed successfully.

END_BYE

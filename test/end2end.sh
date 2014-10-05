#!/bin/sh
#
# Test that ezvm is working
#

testdir="$(dirname "$(readlink -f "$0")")"

export EZVM_BASE_DIR="$(dirname "$testdir")"

. "$testdir/include.sh"

export EZVM_LOCAL_CONTENT_DIR="$testdir/fixtures"

cat <<END_HELO

Beginning end-to-end ezvm test.
You will see all the update fixtures get run in ascending order.
At the end you will see a success message.

==========

END_HELO

"$(dirname "$testdir")/bin/ezvm" update -s $@ || exit $?

# Now let's do some cleanup stuff.  It's annoying that there is a file
# in the home directory after running this test.

rm -f "$HOME/ezvm-home-dir-copy-test.txt" 2> /dev/null

cat <<END_BYE

==========

ezvm update completed successfully.

END_BYE

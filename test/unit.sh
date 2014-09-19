#!/bin/sh
#
# Run unit tests
#

testdir="$(dirname $0)"

export EZVM_BASE_DIR="$(dirname $("$testdir/../bin/realpath" "$testdir"))"
export EZVM_FIXTURES_DIR="$EZVM_BASE_DIR/test/fixtures"

. "$testdir/include.sh"

### Unit tests

# Get a list of all the tests, in the order that they should be run
for f in $(find "$testdir/tests" -type f -name "*.test" -print | sed -e "s,^$testdir/tests/,," | sort); do
	"$testdir/tests/$f" || die
done

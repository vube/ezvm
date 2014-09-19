#
# Common libs for test scripts
#

EZVM_TEST_FILE="$0"
EZVM_TEST_FUNCTION="unknown"
EZVM_TEST_COUNT=0

die() { msg="$@"; [ -z "$msg" ] || echo "ERROR: $msg" 1>&2; exit 1; }

fail() {
	msg="$1"
	echo "[FAIL] " 1>&2
	echo "Test #$EZVM_TEST_COUNT ($EZVM_TEST_FUNCTION) in $EZVM_TEST_FILE" 1>&2
	die "$msg"
}

execEzvm() {

	command="$1"; shift

	export EZVM_LOCAL_CONTENT_DIR="$EZVM_FIXTURES_DIR"

	"$EZVM_BASE_DIR/bin/ezvm" $command -V 100 $@
}

execFixture() {

	execEzvm "exec" $@
}

runTest() {

	EZVM_TEST_FUNCTION="$1"
	EZVM_TEST_COUNT=$(($EZVM_TEST_COUNT + 1))

	printf "%s" "Run test: $EZVM_TEST_FUNCTION "
	output=$($EZVM_TEST_FUNCTION)
	echo "[OK]"
}

printReport() {

	echo "+ $EZVM_TEST_COUNT tests in $EZVM_TEST_FILE"
}

autoRunTests() {

	# Create a temp file
	tempf=$(mktemp -t "ezvm_tests.XXXXX")

	# Get a list of all tests in this file
	# grep for lines looking like
	# test_name() {
	# and save the "test_name" to the temp file
	grep "^test_.*()[[:space:]]*{" "$EZVM_TEST_FILE" | sed -e 's,[[:space:]]*().*,,' > "$tempf"

	# Save all the test names into $funcs
	funcs="$(cat "$tempf")"

	# Remove the temp file
	rm -f "$tempf"

	# Execute all the tests
	for func in $funcs; do
		runTest $func
	done

	# Print a report of what we've done here
	printReport
}

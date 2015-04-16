#
# ezvm exec
#
# This is slurped by ezvm and runs in the same process as it.
#

WITH_SELF_UPDATE=0

ORIGINAL_ARGS=$@
EZVM_TEST_MODE=${EZVM_TEST_MODE:-0}

EZVM_EXEC_FILTER=""

while getopts ":d:F:hqTV:" flag; do
    case "$flag" in
        d)
            EZVM_LOCAL_CONTENT_DIR="$OPTARG"
            ;;
        F)
            EZVM_EXEC_FILTER="$OPTARG"
            ;;
        h)
            printUsageAndExit ;;
        q)
            export EZVM_VERBOSITY=0
            ;;
        T)
            export EZVM_TEST_MODE=1
            ;;
        V)
            export EZVM_VERBOSITY="$OPTARG"
            ;;
        *)
            printUsageAndExit ;;
    esac
done
shift $((OPTIND-1))

# Additional arguments
EZVM_EXEC_FILE="${@:-}"

# If they did NOT give us a filter, then additional arguments are required
if [ -z "$EZVM_EXEC_FILTER" ]; then
    if [ -z "$EZVM_EXEC_FILE" ]; then
        # Lack of additional arguments means we have nothing to exec, that's a usage error
        printUsageAndExit
    fi
elif [ ! -z "$EZVM_EXEC_FILE" ]; then
    # Filter is not empty, and file is not empty
    # That's a paradox, you can't specify them both.  Ignore the filter.
    log_msg 1 "WARNING: Ignoring your exec filter, you passed specific update args"
    log_msg 1 "WARNING: See usage for more info."
    EZVM_EXEC_FILTER=""
fi

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG

$0 exec $ORIGINAL_ARGS
Working on BASE=$EZVM_BASE_DIR

Exec File: $EZVM_EXEC_FILE
Exec Filter: $EZVM_EXEC_FILTER

END_LOG

$EZVM_BIN_DIR/verbose-log 20 <<END_LOG
User: `id`
Environment:
`env | sort | grep -v "^LS_COLORS="`

END_LOG

# Here we'll just run the update-procedure after we've set up a limited number
# of update scripts to execute.
( . $EZVM_COMMANDS_DIR/utilities/update-procedure.sh ) || die "update procedure failed" $?

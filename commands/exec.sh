#
# ezvm exec
#
# This is slurped by ezvm and runs in the same process as it.
#

WITH_SELF_UPDATE=0

ORIGINAL_ARGS=$@

while getopts ":d:F:qV:" flag; do
    case "$flag" in
        d)
            EZVM_LOCAL_CONTENT_DIR="$OPTARG"
            ;;
        F)
            EZVM_EXEC_FILTER="$OPTARG"
            ;;
        q)
            export EZVM_VERBOSITY=0
            ;;
        V)
            export EZVM_VERBOSITY="$OPTARG"
            ;;
        *)
            printUsageAndExit ;;
    esac
done
shift $((OPTIND-1))

# If there is an extra arg, that is the update file
if [ ! -z "$1" ]; then
    EZVM_EXEC_FILE="$1"
    if [ ! -z "$EZVM_EXEC_FILTER" ]; then
        log_msg 1 "Warning: Ignoring your exec filter, you passed a specific exec filename"
        log_msg 1 "Warning: See usage for more info."
    fi
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
`env`

END_LOG

# Here we'll just run the update-procedure after we've set up a limited number
# of update scripts to execute.
( . $EZVM_COMMANDS_DIR/utilities/update-procedure.sh ) || die "update procedure failed" $?

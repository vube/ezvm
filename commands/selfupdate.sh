#
# ezvm selfupdate
#

ORIGINAL_ARGS=$@
EZVM_TEST_MODE=${EZVM_TEST_MODE:-0}

while getopts ":qTV:" flag; do
    case "$flag" in
        q)
            export EZVM_VERBOSITY=0
            ;;
        T)
            EZVM_TEST_MODE=1
            ;;
        V)
            export EZVM_VERBOSITY="$OPTARG"
            ;;
        *)
            printUsageAndExit ;;
    esac
done
shift $((OPTIND-1))

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG

$0 selfupdate $ORIGINAL_ARGS

END_LOG

log_msg 1 "Pulling latest ezvm release from Github"

if ! cd "$EZVM_BASE_DIR"; then
    die "Cannot cd to EZVM_BASE_DIR: $EZVM_BASE_DIR" 4
fi

# If we're NOT in TEST mode
if [ "$EZVM_TEST_MODE" = 0 ]; then
    # Try to pull from git
    if ! git pull; then
        die "git pull failed" 3
    fi
fi

# Now if there is a self-update-hook in the local content dir,
# execute that so the local content can update itself.

if [ -x "$EZVM_LOCAL_CONTENT_DIR/self-update-hook" ]; then

    log_msg 3 "Executing Local Content self-update-hook"

    "$EZVM_LOCAL_CONTENT_DIR/self-update-hook" || die "Local content self-update-hook failed" $?
fi

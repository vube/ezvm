#
# ezvm update
#
# This is slurped by ezvm and runs in the same process as it.
#

WITH_SELF_UPDATE=0
ORIGINAL_ARGS=$@

while getopts ":qsV:" flag; do
    case "$flag" in
        q)
            export EZVM_VERBOSITY=0
            ;;
        s)
            WITH_SELF_UPDATE=1
            ;;
        V)
            export EZVM_VERBOSITY=$OPTARG
            ;;
        *)
            printUsageAndExit ;;
    esac
done
shift $((OPTIND-1))

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG

$0 update $ORIGINAL_ARGS
Working on BASE=$EZVM_BASE_DIR

END_LOG

# If we are updating ezvm itself as well, do that first

if [ $WITH_SELF_UPDATE = 1 ]; then
    log_msg 1 "Updating ezvm..."

    # run `ezvm selfupdate` in a sub-shell so it doesn't modify our variables
    ( . $EZVM_COMMANDS_DIR/selfupdate.sh ) || exit $?
fi

# Now it's quite possible that all the files we rely on have changed.
# Maybe even the files we've already run and executed.

/bin/bash $EZVM_COMMANDS_DIR/utilities/update-procedure.sh || exit $?

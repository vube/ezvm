#
# ezvm update
#
# This is slurped by ezvm and runs in the same process as it.
#

WITH_SELF_UPDATE=0

ORIGINAL_ARGS=$@

while getopts ":d:qsSV:" flag; do
    case "$flag" in
        d)
            EZVM_LOCAL_CONTENT_DIR="$OPTARG"
            ;;
        q)
            export EZVM_VERBOSITY=0
            ;;
        s)
            WITH_SELF_UPDATE=1
            ;;
        S)
            WITH_SELF_UPDATE=0
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

$0 update $ORIGINAL_ARGS
Working on BASE=$EZVM_BASE_DIR

User: `id`
Environment:
`env`

END_LOG

# If we are updating ezvm itself as well, do that first

if [ $WITH_SELF_UPDATE = 1 ]; then
    log_msg 1 "Updating ezvm..."

    # run `ezvm selfupdate` in a sub-shell so it doesn't modify our variables
    ( . $EZVM_COMMANDS_DIR/selfupdate.sh ) || die "self update failed" $?

    # Now start `ezvm update` in a new shell so that any/all updates to self
    # take effect.
    #
    # Here we append the -S (NO self update) flag to the end, so that we effectively
    # remove the -s flag which is buried somewhere in $ORIGINAL_ARGS

    log_msg 10 "Re-running ezvm update with -S (no selfupdate) flag"
    $EZVM_BASE_DIR/bin/ezvm update $ORIGINAL_ARGS -S || die "ezvm update failed: exit code=$?" $?
else

    # Not running selfupdate, so just run the update procedure
    ( . $EZVM_COMMANDS_DIR/utilities/update-procedure.sh ) || die "update procedure failed" $?
fi

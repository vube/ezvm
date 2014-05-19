#
# ezvm update
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

$BASE_DIR/bin/verbose-log 2 <<END_LOG
#
# $0 update $ORIGINAL_ARGS
# Working on BASE=$BASE_DIR
#
END_LOG

if [ $WITH_SELF_UPDATE = 1 ]; then
    log_msg 1 "Updating ezvm..."
    # run `ezvm selfupdate` in a sub-shell so it doesn't modify our variables
    ( . $BASE_DIR/commands/selfupdate.sh ) || exit $?
    echo "ORIGINAL_ARGS=$ORIGINAL_ARGS"
fi

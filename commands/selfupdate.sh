#
# ezvm selfupdate
#

ORIGINAL_ARGS=$@

while getopts ":qV:" flag; do
    case "$flag" in
        q)
            export EZVM_VERBOSITY=0
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
#
# $0 selfupdate $ORIGINAL_ARGS
#
END_LOG

log_msg 1 "Pulling latest ezvm release from Github"

if ! git pull; then
    # `git pull` failed!
    {
        echo
        echo "FATAL: git pull failed"
        echo
    } 1>&2
    exit 3
fi

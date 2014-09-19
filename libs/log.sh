
# log_msg $level $message
#
# Log the message $message IFF the log verbosity is greater than $level
#
log_msg() {
    level=$1
    shift

    echo "$@" | $EZVM_BIN_DIR/verbose-log -c "-" $level
}

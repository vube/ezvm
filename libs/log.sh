
# log_msg $level $message
#
# Log the message $message IFF the log verbosity is greater than $level
#
# Log $level means:
#     1     Notice - Default verbosity level
#    10     Info
#    50+    Debug
#    80+    Trace (LOTS of output)
#
log_msg() {
    level=$1
    shift

    echo "$@" | $EZVM_BIN_DIR/verbose-log -c "-" $level
}

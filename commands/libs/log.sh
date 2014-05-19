log_msg() {
    level=$1
    shift

    echo $@ | $EZVM_BIN_DIR/verbose-log -c "-" $level
}

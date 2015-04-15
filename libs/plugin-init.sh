#!/bin/sh

. $EZVM_BASE_DIR/libs/settings.sh
. $EZVM_BASE_DIR/libs/common.sh
. $EZVM_BASE_DIR/libs/log.sh
. $EZVM_BASE_DIR/libs/sudo.sh

log_msg 5 "update plugin: $0"

# Print out current environment in debug verbosity
# We explicitly remove the "LS_COLORS" variable, it is used by the interactive shell to determine what colors
# everything is, and it's completely useless to us and a HUGE amount of output for no reason.  So we squelch it.

$EZVM_BASE_DIR/bin/verbose-log 50 <<EOF
Environment:
`env | sort | grep -v "^LS_COLORS="`

EOF

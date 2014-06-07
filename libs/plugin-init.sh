#!/bin/sh

. $EZVM_BASE_DIR/libs/settings.sh
. $EZVM_BASE_DIR/libs/common.sh
. $EZVM_BASE_DIR/libs/log.sh

log_msg 5 "update plugin: $0"

$EZVM_BASE_DIR/bin/verbose-log 50 <<EOF
Environment:
`env`

EOF

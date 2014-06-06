#
# first-time-setup
#
# Run by update-procedure.sh if it looks like it hasn't already been run
#

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG
commands/utilities/first-time-setup.sh

END_LOG

if [ -e $FIRST_TIME_SETUP_FILE ]; then
    warn "First time setup has already been run on this machine; running anyway..."
fi

FIRST_TIME_SETUP_DIR=$(dirname $FIRST_TIME_SETUP_FILE)

if [ ! -d $FIRST_TIME_SETUP_DIR ]; then
    log_msg 1 "Creating first time setup dir: $FIRST_TIME_SETUP_DIR"
    mkdir -p $FIRST_TIME_SETUP_DIR || die "Cannot create first time setup dir: $FIRST_TIME_SETUP_DIR" 12
fi

# Copy the user home dirs (if any) onto the machine
. $EZVM_BASE_DIR/libs/copy-home-dir.sh
copy_home_dir

log_msg 1 "First time setup completed successfully"
date > $FIRST_TIME_SETUP_FILE

exit 0

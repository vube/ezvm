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

# If there is a home directory in the local content dir (etc/local by default)
# then we want to copy it to the system.
EZVM_HOME_SRC=${EZVM_HOME_SRC:-"$EZVM_LOCAL_CONTENT_DIR/home"}
if [ -d $EZVM_HOME_SRC ]; then

    # If there is a version specifically for the current user, use that version
    # instead of the default version
    if [ -d "$EZVM_HOME_SRC/users/$EZVM_USERNAME" ]; then
        EZVM_HOME_SRC="$EZVM_HOME_SRC/users/$EZVM_USERNAME"
    fi

    log_msg 3 "cp -rf $EZVM_HOME_SRC $HOME"
    cp -rf $EZVM_HOME_SRC $HOME || die "Failed to copy home directory files from $EZVM_HOME_SRC to $HOME" $?
fi

log_msg 1 "First time setup completed successfully"
date > $FIRST_TIME_SETUP_FILE

exit 0

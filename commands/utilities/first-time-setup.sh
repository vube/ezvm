#
# first-time-setup
#
# Run by update-procedure.sh if it looks like it hasn't already been run
#

# Slurp up useful libs
. $EZVM_COMMANDS_DIR/libs/settings.sh
. $EZVM_COMMANDS_DIR/libs/log.sh

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG

commands/utilities/first-time-setup.sh

END_LOG


if [ -e $FIRST_TIME_SETUP_FILE ]; then
    echo "Warning: First time setup has already been run on this machine; running anyway..." 1>&2
fi

FIRST_TIME_SETUP_DIR=$(dirname $FIRST_TIME_SETUP_FILE)

if [ ! -d $FIRST_TIME_SETUP_DIR ]; then
    log_msg 1 "Creating first time setup dir: $FIRST_TIME_SETUP_DIR"
    mkdir -p $FIRST_TIME_SETUP_DIR || exit 12
fi

# If there is a home directory in the local content dir (etc/local by default)
# then we want to copy it to the system.
HOME_SRC="$LOCAL_CONTENT_DIR/home"
if [ -d $HOME_SRC ]; then

    # If there is a version specifically for the current user, use that version
    # instead of the default version
    if [ -d "$HOME_SRC/users/$LOCAL_USERNAME" ]; then
        HOME_SRC="$HOME_SRC/users/$LOCAL_USERNAME"
    fi

    log_msg 3 "cp -rf $HOME_SRC $HOME"
    cp -rf $HOME_SRC $HOME
fi

log_msg 1 "First time setup completed successfully"
date > $FIRST_TIME_SETUP_FILE

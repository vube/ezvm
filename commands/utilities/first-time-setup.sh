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


## TODO: first-time-setup logic goes here


log_msg 1 "First time setup completed successfully"
touch $FIRST_TIME_SETUP_FILE

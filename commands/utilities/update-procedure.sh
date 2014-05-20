#
# update-procedure
#
# This contains the actual logic for how to do the update.
# `ezvm update` runs this after it runs `ezvm selfupdate`, if applicable.
#

# Slurp up useful libs
. $EZVM_COMMANDS_DIR/libs/settings.sh
. $EZVM_COMMANDS_DIR/libs/log.sh

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG

commands/utilities/update-procedure.sh

END_LOG

if [ ! -e $FIRST_TIME_SETUP_FILE ]; then
    log_msg 1 "Executing first time setup..."
    /bin/bash $EZVM_COMMANDS_DIR/utilities/first-time-setup.sh || exit $?
fi


## TODO: update what we've got here


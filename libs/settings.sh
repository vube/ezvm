#
# Common settings
#

export EZVM_BASE_DIR=${EZVM_BASE_DIR:-/usr/local/ezvm}
export EZVM_VERBOSITY=${EZVM_VERBOSITY:-1}


EZVM_BIN_DIR="$EZVM_BASE_DIR/bin"
EZVM_COMMANDS_DIR="$EZVM_BASE_DIR/commands"
EZVM_ETC_DIR="$EZVM_BASE_DIR/etc"


# Location where we will store/check first time setup status;
# After first time setup has run this file will exist.
FIRST_TIME_SETUP_FILE=$EZVM_ETC_DIR/.ezvm/first-time-setup

# If they set the EZVM_USERNAME environment variable, use it;
# otherwise default to the USER environment variable.
EZVM_USERNAME=${EZVM_USERNAME:-$USER}

EZVM_LOCAL_CONTENT_DIR=${EZVM_LOCAL_CONTENT_DIR:-$EZVM_ETC_DIR/local}
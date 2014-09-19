#
# Common settings
#

export EZVM_BASE_DIR=${EZVM_BASE_DIR:-/usr/local/ezvm}
export EZVM_VERBOSITY=${EZVM_VERBOSITY:-1}


EZVM_BIN_DIR="$EZVM_BASE_DIR/bin"
EZVM_COMMANDS_DIR="$EZVM_BASE_DIR/commands"
EZVM_ETC_DIR="$EZVM_BASE_DIR/etc"

# EZVM_IS_WINDOWS = YES|NO
# optimization so we only have to calculate it once
# If it's not yet calculated it's empty
EZVM_IS_WINDOWS=${EZVM_IS_WINDOWS:-""}

if [ -z "$EZVM_IS_WINDOWS" ]; then
	# By default = NO
	EZVM_IS_WINDOWS="NO"
	# Windows 7 & 8.1 set OS=Windows_NT environment variable,
	# so check to see if that's set
	if [ ! -z "$OS" ]; then
	    if echo "$OS" | grep -i '^Windows' > /dev/null; then
	    	# It looks like Windows
	    	EZVM_IS_WINDOWS="YES"
	    fi
	fi
	# Export this so we don't have to calculate it again
	export EZVM_IS_WINDOWS
fi


# Location where we will store/check first time setup status;
# After first time setup has run this file will exist.
FIRST_TIME_SETUP_FILE=$EZVM_ETC_DIR/.ezvm/first-time-setup

# If they set the EZVM_USERNAME environment variable, use it;
# otherwise default to the USER environment variable.
#
# Default: $USER environment variable
#
EZVM_USERNAME=${EZVM_USERNAME:-$USER}

# Local Content Dir is where you should store all of your update scripts
# and any other content you need for your update scripts to function.
#
# Default: /usr/local/ezvm/etc/local
#
EZVM_LOCAL_CONTENT_DIR=${EZVM_LOCAL_CONTENT_DIR:-$EZVM_ETC_DIR/local}

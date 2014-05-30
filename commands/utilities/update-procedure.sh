#
# update-procedure
#
# This contains the actual logic for how to do the update.
# `ezvm update` runs this after it runs `ezvm selfupdate`, if applicable.
#

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG

commands/utilities/update-procedure.sh

END_LOG

if [ ! -e $FIRST_TIME_SETUP_FILE ]; then
    log_msg 1 "Executing first time setup..."
    ( . $EZVM_COMMANDS_DIR/utilities/first-time-setup.sh ) || die "first time setup failed" $?
fi


## TODO: update what we've got here


EZVM_UPDATE_DIR=${EZVM_UPDATE_DIR:-"$EZVM_LOCAL_CONTENT_DIR/update"}

if [ -d $EZVM_UPDATE_DIR ]; then

    have_sudo=0
    have_root=0

    # Find out if we have sudo on this system.
    # Some systems do not use sudo.
    if which sudo > /dev/null 2>&1; then
        have_sudo=1
     else
        log_msg 4 "Notice: sudo is not found on this system"

        # We don't have sudo, we need to know if we have a root user
        # on this system. Some systems (cygwin) do not.
        if su -c "exit" root > /dev/null 2>&1; then
            have_root=1
        else
            log_msg 4 "Notice: there is no root user on this system"
        fi
     fi


    cd $EZVM_UPDATE_DIR || die "Cannot cd to EZVM_UPDATE_DIR: $EZVM_UPDATE_DIR"

    for f in `ls`; do

        # Skip directories
        [ -d $f ] && continue

        # Skip files that are not executable
        [ -x $f ] || continue

    	# See if the filename ends in ".ROOT"
    	as_root=0
        echo "$f" | grep -q '\.ROOT$' && as_root=1

        done=0

        # Which command will we run
        #
        command="./$f"

        # If we should try to run this as root, then do so
        if [ $as_root = 1 ]; then

            log_msg 2 ""
            log_msg 2 "ROOT SETUP: $f"
            log_msg 2 ""

            if [ $have_sudo = 1 ]; then
                # We have sudo on this system
                sudo su -c "$command" || die "$f exit code=$?" $?
                # Don't try to run this as a regular user
                done=1
            elif [ $have_root = 1 ]; then
                # There is no sudo, but there is a root user
                su -c "$command" root || die "$f exit code=$?" $?
                # Don't try to run this as a regular userr
                done=1
            else
                # There is neither sudo nor a root user on this system
                log_msg 7 "Notice: Cannot run $f as root, no sudo or root user exists"
            fi
        fi

        # If we haven't been able to run it yet, then run it as an
        # ordinary user account.
        if [ $done = 0 ]; then

            log_msg 2 ""
            log_msg 2 "user setup: $f"
            log_msg 2 ""

            $command || die "$f exit code=$?" $?

    	fi

    done
fi


exit 0

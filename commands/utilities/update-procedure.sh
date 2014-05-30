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


EZVM_UPDATE_DIR=${EZVM_UPDATE_DIR:-"$EZVM_LOCAL_CONTENT_DIR/update"}

if [ -d $EZVM_UPDATE_DIR ]; then

    cd $EZVM_UPDATE_DIR || die "Cannot cd to EZVM_UPDATE_DIR: $EZVM_UPDATE_DIR"

    have_sudo=0
    haveSudo && have_sudo=1

    have_root=0
    haveRootUser && have_root=1

    for f in `ls`; do

        # Skip directories
        [ -d $f ] && continue

        # Skip files that are not executable
        [ -x $f ] || continue

    	# See if the filename ends in ".ROOT"
    	as_user="$USER"
        echo "$f" | grep -q '\.ROOT$' && as_user="root"

        command_type="Update"
        [ "$as_user" = "root" ] && command_type="ROOT Update"

        log_msg 1 "#"
        log_msg 1 "# $command_type command: $f"
        log_msg 1 "#"

        runCommandAsUser "./$f" "$as_user" || die "Exit code=$? from command: $f" $?

    done
fi

exit 0

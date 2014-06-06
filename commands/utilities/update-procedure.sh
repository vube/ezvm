#
# update-procedure
#
# This contains the actual logic for how to do the update.
# `ezvm update` runs this after it runs `ezvm selfupdate`, if applicable.
#

EZVM_UPDATE_DIR=${EZVM_UPDATE_DIR:-"$EZVM_LOCAL_CONTENT_DIR/update"}

EZVM_EXEC_FILE=${EZVM_EXEC_FILE:-""}
EZVM_EXEC_FILTER=${EZVM_EXEC_FILTER:-""}

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG
commands/utilities/update-procedure.sh

END_LOG


if [ -d "$EZVM_UPDATE_DIR" ]; then

    changeDir "$EZVM_UPDATE_DIR"

    # If they gave us one specific file to execute, set $files
    files="$EZVM_EXEC_FILE"

    if [ -z "$files" ]; then
        # $files is empty, there is no specific file, so list ALL update files and execute them all,
        # possibly applying a filename filter

        if [ -z "$EZVM_EXEC_FILTER" ]; then
            # There is no filter, list all update files
            files=`ls`;
        else
            # There is a filter, list all files that match the filter
            files=$(ls | egrep "$EZVM_EXEC_FILTER")
        fi

    fi

    # For every file that we want to execute, execute it

    for f in $files; do

        # Skip files that don't exist
        # This is possible if they specified EZVM_EXEC_FILE="non-existing-filename"
        if [ ! -e "$f" ]; then
            log_msg 1 "Warning: No such update script: $f"
            continue
        fi

        # Skip directories
        if [ -d "$f" ]; then
            log_msg 9 "Skip directory: $f"
            continue
        fi

        # Skip files that are not executable
        if [ ! -x "$f" ]; then
            log_msg 9 "Skip non-executable file: $f"
            continue
        fi

    	# See if the filename ends in ".ROOT" or (contains ".ROOT." or "-ROOT-" or some combination thereof)
    	as_user="$USER"
        echo "$f" |  egrep -q '[\.\-]ROOT([\.\-]|$)' && as_user="root"

        command_type="Update"
        [ "$as_user" = "root" ] && command_type="ROOT Update"

        log_msg 1 "#"
        log_msg 1 "# $command_type command: $f"
        log_msg 1 "#"

        runCommandAsUser "./$f" "$as_user" || die "Exit code=$? from command: $f" $?

    done

else
    log_msg 1 "Notice: No update dir exists: $EZVM_UPDATE_DIR"
fi

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

        if [ -x "get-update-list" ]; then

            # There is an application here that will tell us what files to execute
            # Note: If get-update-list fails, that means something is wrong with the
            # local update files, and we should die

            log_msg 10 "Executing get-update-list to generate update file list"
            files="$(./get-update-list)" || die "get-update-list failed with code $?"

        elif [ -z "$EZVM_EXEC_FILTER" ]; then
            # There is no filter, list all update files
            files="$(ls | sort)"
        else
            # There is a filter, list all files that match the filter
            files="$(ls | egrep "$EZVM_EXEC_FILTER" | sort)"
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

        # Skip the special reserved name "get-update-list"
        if [ "$(echo "$f" | egrep -i '^(./)?get-update-list$')" != "" ]; then
            # If they specifically ran this with `ezvm exec get-update-list` then let it run
            # Otherwise DO NOT let it run, it's a reserved name
            if [ "$f" != "$EZVM_EXEC_FILE" ]; then
                # They did not invoke with `ezvm exec get-update-list`
                log_msg 9 "Skip reserved file get-update-list"
                continue
            fi
        fi

    	# See if the filename ends in ".ROOT" or (contains ".ROOT." or "-ROOT-" or some combination thereof)
    	as_user="$USER"
        echo "$f" |  egrep -q '[\.\-]ROOT([\.\-]|$)' && as_user="root"

        command_type="Update"
        [ "$as_user" = "root" ] && command_type="ROOT Update"

        # No prefix if $f is an absolute filename
        prefix=""

        # IF $f is NOT an absolute filename
        if [ "$(echo "$f" | grep -q '^/')" = "" ]; then
            # Then remove any leading "./" that MIGHT be there
            # and add a leading "./" so we KNOW it is there
            f="$(echo "$f" | sed -e 's,^\.//*,,')"
            # For relative filenames, prefix with "./" to execute them
            prefix="./"
        fi

        log_msg 1 "#"
        log_msg 1 "# $command_type command: $f"
        log_msg 5 "# Current Dir: $(pwd)"
        log_msg 1 "#"

        if [ -e "$f" ]; then
            log_msg 80 "# File $f does exist"
            log_msg 80 "# If you are getting errors about file not existing here,"
            log_msg 80 "# it means your hashbang is wrong in the script we are trying"
            log_msg 80 "# to run. Have a CRLF in it maybe? :)"
        fi

        runCommandAsUser "$prefix$f" "$as_user" || die "Exit code=$? from command: $f" $?

    done

else
    log_msg 1 "Notice: No update dir exists: $EZVM_UPDATE_DIR"
fi

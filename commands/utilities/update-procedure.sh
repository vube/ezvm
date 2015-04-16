#
# update-procedure
#
# This contains the actual logic for how to do the update.
# `ezvm update` runs this after it runs `ezvm selfupdate`, if applicable.
#

EZVM_UPDATE_DIR=${EZVM_UPDATE_DIR:-"$EZVM_LOCAL_CONTENT_DIR/update"}

EZVM_EXEC_FILE=${EZVM_EXEC_FILE:-""}
EZVM_EXEC_FILTER=${EZVM_EXEC_FILTER:-""}

EZVM_TEST_MODE=${EZVM_TEST_MODE:-0}

$EZVM_BIN_DIR/verbose-log 2 <<END_LOG
commands/utilities/update-procedure.sh

END_LOG


if [ -d "$EZVM_UPDATE_DIR" ]; then

    changeDir "$EZVM_UPDATE_DIR"

    # If they gave us one or more specific files to execute, set $files
    files="$EZVM_EXEC_FILE"

    if [ -z "$files" ]; then
        # $files is empty, there is no specific file, so list ALL update files and execute them all,
        # possibly applying a filename filter

        if [ -x "get-update-list" ]; then

            # There is an application here that will tell us what files to execute
            # Note: If get-update-list fails, that means something is wrong with the
            # local update files, and we should die

            log_msg 10 "Executing get-update-list to generate update file list"

            tmp="$(mktemp -t ezvm.XXXXXX)"
            ./get-update-list > $tmp || die "get-update-list failed with code $?"

            # It's useful to allow get-update-list to print debug info
            # Ignore all lines prefixed with DEBUG:, those are not update files
            # Also ignore any comments (lines beginning with # or -)
            files=$(cat $tmp | grep -v "^DEBUG:" | grep -v "^[#\-]")

            # If there is debug info in the get-update-list output, send it through
            # so we can see it when we are running ezvm
            tmp2="$(mktemp -t ezvm.XXXXXX)"
            cat $tmp | grep "^DEBUG:" > $tmp2
            if [ -s $tmp2 ]; then
                # Log this at DEBUG level; you need to turn up verbosity to see this
                log_msg 50 "$(cat $tmp2 | sed -e 's,^,get-update-list: ,g')"
            fi

            # Clean up temp files
            rm -f $tmp $tmp2

            log_msg 50 "get-update-list Returned these files:"

            for f in $files; do
                log_msg 50 "  - $f"
            done

        elif [ -z "$EZVM_EXEC_FILTER" ]; then
            # There is no filter, list all update files
            files="$(ls | sort)"
        else
            # There is a filter, list all files that match the filter
            files="$(ls | egrep "$EZVM_EXEC_FILTER" | sort)"
        fi

    fi

    # Resolve any directories that need to be executed
    # Expand the directories to a list of files in the directory.

    filesExpanded=""

    for f in $files; do
        # If this is a directory, then expand it to the files inside that directory
        # This is NOT a recursive expansion
        if [ -d "$f" ]; then
            log_msg 9 "Expand exec directory: $f"
            filesExpanded="$filesExpanded $(find "$f" -maxdepth 1 -type f -print | sort)"
        else
            filesExpanded="$filesExpanded $f"
        fi
    done

    files="$filesExpanded"

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

        if [ "$EZVM_TEST_MODE" = 0 ]; then
            runCommandAsUser "$prefix$f" "$as_user"
            r=$?
        else
            log_msg 1 "# TEST MODE: Would have executed as $as_user: $prefix$f"
            r=0
        fi

        if [ "$r" != 0 ]; then

            log_msg 1 "# ERROR running command $f; exit code=$r"

            if [ -e "$f" ]; then
                log_msg 1 "File $f does exist"
                log_msg 1 "If you are getting errors about file not existing here,"
                log_msg 1 "it means your hashbang is wrong in the script we are trying"
                log_msg 1 "to run. Have a CRLF in it maybe? :)"
            fi

            die "Exit code=$r from command: $f" $r
        fi

    done

else
    log_msg 1 "Notice: No update dir exists: $EZVM_UPDATE_DIR"
fi

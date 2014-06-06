# libs/copy_home_dir.sh
#
# Sub-routines to handle copying a user's homedir to the local machine.
# You can make an update script that calls this if you want to allow
# this to happen every time you `ezvm update`
#


# If there is a home directory in the local content dir (etc/local by default)
# then we want to copy it to the system.
EZVM_HOME_SRC=${EZVM_HOME_SRC:-"$EZVM_LOCAL_CONTENT_DIR/home"}


# Copy home source to $HOME
# Usage: copy_home_src $source_directory
copy_home_dir_src() {

    local src="$1"
    local files="$(find "$src" -maxdepth 1 | sed -e "s,^$src/*,," | grep -v '^users$')"
    local f

    log_msg 7 "Copying home dir files from $src"

    for f in $files; do
        log_msg 9 "Overwrite: $HOME/$f"
        cp -r "$src/$f" "$HOME/$f" || die "Error copying $f" $?
    done
}


# Copy the default home directory from the local source to the current machine.
# If there is also a specific user home directory, copy that too.
# Usage: copy_home_dir
copy_home_dir() {

    if [ -d $EZVM_HOME_SRC ]; then

        log_msg 5 "Copying generic home dir source"
        copy_home_dir_src "$EZVM_HOME_SRC"

        # If there is a version specifically for the current user, use that version
        # in addition to the default version
        if [ -d "$EZVM_HOME_SRC/users/$EZVM_USERNAME" ]; then

            log_msg 5 "Copying user-specific home dir source"
            copy_home_dir_src "$EZVM_HOME_SRC/users/$EZVM_USERNAME"
        fi

    else

        log_msg 10 "Notice: No home dir source dir exists: $EZVM_HOME_SRC"
    fi
}

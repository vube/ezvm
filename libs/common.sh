# libs/common.sh
#
# Common shell sub-routines that should be available to all scripts.
#

warn() {

    echo "Warning: $1" 1>&2
}

die() {
    local exitCode=${2:-1}

	echo "FATAL ERROR: $1" 1>&2
	exit $exitCode
}

changeDir() {
    local dir="$1"

    log_msg 80 "cd $dir"
    cd "$dir" || die "Cannot cd $dir"
}

createDir() {

    local dir="$1"
    local mode="${2:-0775}"
    local group="${3:-}"
    local user="${4:-$USER}"

    # The default group is the user's group
    if [ -z "$group" ]; then
        group=$(id --group $user)
    fi

	if [ ! -d "$dir" ]; then
	    install -d -m "$mode" -g "$group" -o "$user" "$dir" || die "Create dir failed: $dir"
	else
	    chmod "$mode" $dir || die "Cannot chmod $mode $dir"
	    chown "$user" $dir || die "Cannot chown $user $dir"
	    chgrp "$group" $dir || die "Cannot chgrp $group $dir"
	fi
}

# libs/git.sh
#
# Common sub-routines for dealing with Git repositories
#


gitCheckout() {

	local repo_ident="$1"
	local base_dir="${2:-`pwd`}"
	local repo_dir="${3:-`basename "$repo_ident"`}"
	local fts_branch="${4:-master}"

    log_msg 1 "==> Git: $repo_ident"

	if [ -d "$base_dir/$repo_dir" ]; then
	    changeDir "$base_dir/$repo_dir"
		git pull || die "git pull failed for $repo_ident"
	else
		# We don't have the repo yet, clone it
		changeDir "$base_dir"
		git clone "$repo_ident" "$repo_dir" || die "Git clone failed for $repo_ident"
		chmod -R g+w "$repo_dir"

		# Change into the repo dir for the later operations
		changeDir "$base_dir/$repo_dir"

		# If we're not on the $fts_branch, change there now
        current_branch=$(git rev-parse --abbrev-ref HEAD)
		if [ "x$current_branch" != "x$fts_branch" -a "x$fts_branch" != "" ]; then
			git checkout "$fts_branch" || die "Cannot checkout fts_branch=$fts_branch"
		fi
	fi

    # Initialize/update submodules, if any
    num_submodules=$(git submodule status | wc -l)
    if [ $num_submodules != 0 ]; then
        git submodule init || die "Cannot init submodules"
        git submodule update || die "Cannot update submodules"
    fi

	# If we're using composer to manage dependencies in this
	# project, then update the dependencies now
	#
	if [ -e composer.json ]; then
		if [ -e composer.lock ]; then
			# They have a composer.lock, so they've already run install.
			# Run update to get latest dependencies if anything has changed.
            composer update || die "composer update failed in $repo_ident"
        else
            # There is no composer.lock, this is the first time we've tried
            # to run composer in this project.  Run install.
            composer install || die "composer install failed in $repo_ident"
        fi
    fi

	log_msg 1 "<== Git: $repo_ident"
}


versionedLibInit() {

	local repo="$1"
	local dir="${2:-`pwd`}"
	local fts_branch="${3:-master}"

	log_msg 1 "==> Init versioned lib: $repo"

    createDir "$dir"            0775
    createDir "$dir/src"        0775

    createDir "$dir/log"        1777

	gitCheckout "$repo" "$dir/src" "$fts_branch" "$fts_branch"

    changeDir "$dir"

	# If they don't already have an active symlink, create one
	# and point it to the $fts_branch source
	if [ ! -d "$dir/active" ]; then
		log_msg 3 "link active -> src/$fts_branch"
		ln -sfT "src/$fts_branch" active || die "Create active symlink failed"
	fi

	log_msg 1 "<== Init versioned lib: $repo"
}


versionedServiceInit() {

	local repo="$1"
	local dir="${2:-`pwd`}"
	local fts_branch="${3:-master}"

	log_msg 1 "==> Init service: $repo"

    versionedLibInit "$repo" "$dir" "$fts_branch"

    createDir "$dir/etc"        0775

    createDir "$dir/log"        1777

	# If they don't have version.php, copy it from the currently
	# active source version
	if [ ! -e etc/version.php ]; then
	    if [ -e active/etc/version.php ]; then
    		log_msg 2 "install active/etc/version.php"
	    	cp -f active/etc/version.php etc/ || die "Cannot copy version.php"
	    fi
	fi

	log_msg 1 "<== Init service: $repo"
}

versionedNodeServiceInit() {

    local repo="$1"
    local dir="${2:-`pwd`}"
    local fts_branch="${3:-master}"
    local supervisor_pgrep="${4:-}"
    local supervisor_command="${5:-}"
    local supervisor_user="${6:-$USER}"

    log_msg 1 "==> Init Node.js service: $repo"

    versionedServiceInit "$repo" "$dir" "$fts_branch"

    # now make sure the supervisor process is started
    if [ "x$supervisor_pgrep" != x -a "x$supervisor_command" != x ]; then
        if ! pgrep -lf "$supervisor_pgrep" ; then

            runCommandAsUser "$supervisor_command" "$supervisor_user" || die "Cannot start supervisor: $supervisor_command" $?
        fi
    fi

    log_msg 1 "<== Init Node.js service: $repo"
}

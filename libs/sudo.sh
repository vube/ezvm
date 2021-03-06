# libs/sudo.sh
#
# Sub-routines related to running scripts with elevated permissions
#

# DON'T use these outside of this lib.  These should be considered
# Private Variables:
EZVM_LIB_SUDO_INIT="${EZVM_LIB_SUDO_INIT:-0}"
EZVM_HAVE_SUDO="${EZVM_HAVE_SUDO:-0}"
EZVM_HAVE_SU="${EZVM_HAVE_SU:-0}"
EZVM_HAVE_ROOT="${EZVM_HAVE_ROOT:-0}"


initSudoLib() {

    # If we already initialized, return immediately
    [ $EZVM_LIB_SUDO_INIT = 1 ] && return

    # Export that we've initialized to the environment, so sub-processes won't have
    # to initialize or test us again.
    export EZVM_LIB_SUDO_INIT=1

    # Find out if we have sudo on this system.
    # Some systems do not use sudo.
    if which sudo > /dev/null 2>&1; then
        export EZVM_HAVE_SUDO=1
    else
        log_msg 4 "Notice: sudo is not found on this system"

        # We don't have sudo, we need to know if we have su
        # on this system. Some systems (cygwin) do not.
        if su -c "exit" "$USER" > /dev/null 2>&1; then
            export EZVM_HAVE_SU=1

            # We have su, do we also have a root user?
            if su -c "exit" root > /dev/null 2>&1; then
                export EZVM_HAVE_ROOT=1
            else
                log_msg 4 "Notice: there is no root user on this system"
            fi
        else
            log_msg 4 "Notice: su is not found on this system"
        fi
    fi
}


# haveSudo && have_sudo=1
# Use this to test if we have `sudo` on this system
# Returns: 0 if we DO HAVE SUDO, 1 if we do NOT have sudo
haveSudo() {
    # Return TRUE(0) if we have sudo, else FALSE(1)
    [ $EZVM_HAVE_SUDO = 1 ] && return 0
    return 1
}


# haveRootUser() && have_root=1
# Use this to test if we have a root user on this system
# Returns: 0 if we DO HAVE ROOT, 1 if we do NOT have root
haveRootUser() {
    # Return TRUE(0) if we have a root user, else FALSE(1)
    [ $EZVM_HAVE_ROOT = 1 ] && return 0
    return 1
}


runCommandAsUser() {

    local command="$1"
    local user="${2:-$USER}"
    local r=0
    local ran=0

    log_msg 80 "runCommandAsUser $user $command"
    log_msg 80 "have sudo = $EZVM_HAVE_SUDO; have root = $EZVM_HAVE_ROOT"
    log_msg 80 "current dir: $(pwd)"

    if [ "$user" = "$USER" ]; then

        # We want to run this as ourselves.  No need to sudo or su or whatever
        # to do that. Skip all this logic and go to the bottom.
        ran=0

    elif [ $EZVM_HAVE_SUDO = 1 ]; then

        # We have sudo on this system
        # sudo -E means preserve ENV vars, it's vital to ezvm that we preserve ENV
        # su -m means preserve ENV vars, it's vital to ezvm that we preserve ENV
        #
        # we use `env USER=$user $command` because otherwise the $USER still says
        # we are who we were before the sudo su (due to preserve env I guess), and
        # that is not desired.
        log_msg 80 "sudo -E su '$user' -m -c 'env USER=$user $command'"
        sudo -E su "$user" -m -c "env USER=$user $command"
        r=$?
        ran=1

    elif [ $EZVM_HAVE_SU = 1 ]; then

        # We have `su`, try to use that to run as the appropriate user

        if [ "$user" = root ]; then

            # We're trying to run this as root

            if [ $EZVM_HAVE_ROOT = 1 ]; then

                # There is no sudo, but there is a root user,
                # and we're trying to run this command as root.
                # -m means preserve ENV vars, it's vital to ezvm that we preserve ENV
                su "$user" -m -c "$command"
                r=$?
                ran=1
            fi

        elif [ "$user" != "$USER" ]; then

            # We're trying to run this as non-root and non-current-user

            # -m means preserve ENV vars, it's vital to ezvm that we preserve ENV
            su "$user" -m -c "$command"
            r=$?
            ran=1
        fi
    fi

    if [ $ran = 0 ]; then
        # There is no way to run this as another user, or we're trying to run it
        # as ourselves anyway.

        if [ "$user" != "$USER" ]; then
            log_msg 2 "Notice: Cannot run command as user=$user, running as $USER"
        fi

        "$command"
        r=$?
    fi

    return $r
}

runCommandAsRoot() {

    runCommandAsUser "$1" root
    return $?
}


# initSudoLib if needed
[ $EZVM_LIB_SUDO_INIT = 1 ] || initSudoLib

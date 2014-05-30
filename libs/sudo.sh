# libs/sudo.sh
#
# Sub-routines related to running scripts with elevated permissions
#

# DON'T use these outside of this lib.  These should be considered
# Private Variables:
EZVM_LIB_SUDO_INIT=0
EZVM_HAVE_SUDO=0
EZVM_HAVE_ROOT=0


initSudoLib() {

    # If we already initialized, return immediately
    [ $EZVM_LIB_SUDO_INIT = 1 ] && return

    EZVM_LIB_SUDO_INIT=1

    # Find out if we have sudo on this system.
    # Some systems do not use sudo.
    if which sudo > /dev/null 2>&1; then
        EZVM_HAVE_SUDO=1
    else
        log_msg 4 "Notice: sudo is not found on this system"

        # We don't have sudo, we need to know if we have a root user
        # on this system. Some systems (cygwin) do not.
        if su -c "exit" root > /dev/null 2>&1; then
            EZVM_HAVE_ROOT=1
        else
            log_msg 4 "Notice: there is no root user on this system"
        fi
    fi
}


# haveSudo && have_sudo=1
# Use this to test if we have `sudo` on this system
# Returns: 0 if we DO HAVE SUDO, 1 if we do NOT have sudo
haveSudo() {
    # initSudoLib if needed
    [ $EZVM_LIB_SUDO_INIT = 1 ] || initSudoLib
    # Return TRUE(0) if we have sudo, else FALSE(1)
    [ $EZVM_HAVE_SUDO = 1 ] && return 0
    return 1
}


# haveRootUser() && have_root=1
# Use this to test if we have a root user on this system
# Returns: 0 if we DO HAVE ROOT, 1 if we do NOT have root
haveRootUser() {
    # initSudoLib if needed
    [ $EZVM_LIB_SUDO_INIT = 1 ] || initSudoLib
    # Return TRUE(0) if we have a root user, else FALSE(1)
    [ $EZVM_HAVE_ROOT = 1 ] && return 0
    return 1
}


runCommandAsUser() {

    local command=$1
    local user=$2
    local r=0

    # initSudoLib if needed
    [ $EZVM_LIB_SUDO_INIT = 1 ] || initSudoLib

    if [ $EZVM_HAVE_SUDO = 1 ]; then

        # We have sudo on this system
        sudo su "$user" -c "$command"
        r=$?

    elif [ $EZVM_HAVE_ROOT = 1 -o "$user" != root ]; then

        # There is no sudo, but there is a root user,
        # or we're trying to run as a non-root user.
        su -c "$command" "$user"
        r=$?

    else

        # There is no way to run this as another user.
        # Just run it as ourselves.

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

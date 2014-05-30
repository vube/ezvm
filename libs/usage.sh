printUsageAndExit() {
    {
        if [ -z $USAGE_FILE ]; then
            echo "Warning: Invalid usage"
            die "Cannot call printUsageAndExit without defining $USAGE_FILE"
        fi

        if [ ! -e $USAGE_FILE ]; then
            echo "Warning: Invalid usage"
            die "No such usage file: $USAGE_FILE"
        fi

        wrote=0

        # If there is an OS environment variable (it gets set by Windows, maybe others)
        if [ ! -z $OS ]; then
            # In Windows we need to send \n\r line endings or the usage isn't readable
            if echo $OS | grep -i '^Windows' > /dev/null; then
                cat $USAGE_FILE | sed -e 's,\n,\n\r,g'
                wrote=1
            fi
        fi

        # If we didn't write it out already, do it now
        [ $wrote = 0 ] && cat $USAGE_FILE

    } 1>&2 # Send all output to STDERR
    exit 1 # Exit with non-success code
}

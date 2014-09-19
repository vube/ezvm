# Easy VM (ezvm)

This app makes it easy for you to update and manage your VMs without having to recreate them
or manually update your stuff.

Ideal for working in teams when the state of your VM is changing, software is being added,
removed, updated and you don't want people to have to do anything other than type `ezvm update`
to get the latest changes applied to their work-in-progress.

Generally speaking if you have items that just need to be installed once when your VM is created,
you're better off putting those things in a Chef recipe and using `vagrant provision` for rare
updates of the VM.

However when you're actively modifying the state of a VM to add/remove things, ezvm can be much
easier to play around with and share your changes with others.

## Installation

```bash
$ git clone https://github.com/vube/ezvm
$ sudo mv ezvm /usr/local/
```

Then either add `/usr/local/ezvm/bin` to your path like

```bash
$ export PATH="$PATH:/usr/local/ezvm/bin"
```

OR you can symlink `ezvm` from `/usr/local/bin` assuming that is already in your path, like:

```bash
$ ln -sf /usr/local/ezvm/bin/ezvm /usr/local/bin/ezvm
```

### Install the realpath package

ezvm prefers to use the `realpath` package.  While it is not strictly required, it is
recommended.

Failure to use the `realpath` package may cause ezvm to break if you installed
it with the symlink method shown above.  If you don't execute `ezvm` from a symlink
then `realpath` is not needed.

#### Installing realpath via Chef

```ruby
package "realpath"
```

#### Installing realpath by hand

```bash
$ sudo apt-get install realpath
```

## Usage

### ezvm update

This will update your VM.

```bash
$ ezvm update
```


### ezvm selfupdate

This will update ezvm itself to the latest release.

```bash
$ ezvm selfupdate
```


### ezvm exec

This is useful for testing your local update procedures.

```bash
$ ezvm exec 010-update-script.sh
```

The above example will run the script `010-update-script.sh` from your local update directory,
by default `$EZVM_BASE_DIR/etc/local/update`


# Testing

The test procedures here are pretty simple, they execute ezvm and you essentially have to verify
that it's working manually.  Old school!

## test/unit.sh

This script will execute the unit tests. It executes all test/tests/*.test scripts unless/until
one of them experiences an error. It exits cleanly if all tests pass.

## test/exec.sh

This allows you to run just single update fixture, same as `ezvm exec`

```bash
$ test/exec.sh 003-copy-home-dir
```

The example above just runs the
[test/fixtures/update/003-copy-home-dir](browse/test/fixtures/update/003-copy-home-dir)
update procedure.  Change it up to
run any specific one you want to test in more detail.

```bash
$ test/exec.sh -V 100 003-copy-home-dir
```

Use `-V 100` to enable a huge amount of debugging output, helpful if you are trying to
figure out why your script isn't working as expected.

## test/end2end.sh

This script executes all of the test update fixtures as if you ran `ezvm update`

If everything works correctly it exits cleanly.

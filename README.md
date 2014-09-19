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

After you configure ezvm, you can use it thusly:

```bash
$ ezvm update
```

The above will update your VM.

```bash
$ ezvm selfupdate
```

The above will update ezvm itself to the latest release.


## Configuration

### etc/local Directory

The `etc/local` directory is the "Local Content Directory". Generally speaking, this is
where you should store your own files.

After you install ezvm you should then copy over the contents of `etc/local` from
your own repository, and then ezvm is ready to run.

The `etc/local` directory is excluded from Git, you must manage this directory.

#### etc/local/update Directory

`etc/local/update` is where you should put all of your update routines.
You should put shell scripts here that will be executed in sorted order.

The special file extension `.ROOT` (dot ROOT) tells ezvm to run this script
as the root user.  If the file extension is not `.ROOT` then it will run with
ordinary user permissions.

See the [test/fixtures/update](browse/test/fixtures/update) directory for a sample
of the kinds of things you could put in `etc/local/update`

##### TODO: Tip for Local Content self-update-hook

TODO: Write an example self-update-hook that will `git pull` the etc/local
contents from whatever repository you store it at.  Thus every time you `ezvm update`
you'll have all the latest copies of your own configs and scripts before updating.

### etc/local/home Directory

This directory is totally optional.

IF this directory exists, then the first time `ezvm update` is run on a machine
(and only the first time) the contents of this directory will be copied to your
home directory.

If you have multiple users who want their own files, each user should make a
directory named `etc/local/home/{username}` where {username} is their username.
If their own directory exists, its contents will be copied ON TOP of the generic
home contents.

If you cannot have specific usernames when you execute ezvm, you can optionally
set the `EZVM_USERNAME` environment variable to emulate running as that user,
and that user's home directory will be copied.

## Advanced Usage

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

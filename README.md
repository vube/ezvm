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

ezvm depends on the `realpath` package.

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

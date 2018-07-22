---
title: "Go modules"
teaser: What are Go modules and how to use them.
image: /images/logo.png
comments: true
category: programming
tags: [go]
---

## Definition
A module is a collection of related go packages. Modules are the unit of
source code interchange and versionning.


## Quick history
- Go before 1.5: populating *GOPATH* with `go get`.
- Go 1.5 and after: dependency vendoring is introduced.
- [vgo] is proposed as a prototype for Go modules support.
- Go 1.11 (beta): `vgo` is being merged and refined as `go mod` (experimental).


## Terminology
This article refers to recurrent expressions. Let's clarify them:

- *"Module root"*: the directory containing the file named `go.mod`.
- *"Module path"*: the import path prefix corresponding to the module root.
- *"Main module"*: the module containing the directory where the `go` command
is run.


## Module structure
A module is a tree of Go source files to which is added a file named *go.mod*.
It contains the module import name, and the declaration of dependency
requirements, exclusions and replacements. Its content would look like this:

```text
module my/thing
  
require (
        one/thing v1.3.2
        other/thing v2.5.0 // indirect
        ...
)

exclude (
        bad/thing v0.7.3
)

replace (
        src/thing 1.0.2 => dst/thing v1.1.0
)
```

Note that a dependency not directly imported in the module's source code by
an import statement is indentified as *indirect* in the file.

A module can contain other modules, in which case their content is excluded
from the parent module.

<div class="image-container">
  <image src="/images/module_structure.png" alt="structure"/>
</div>

Alongside *go.mod*, a file named `go.sum` may be present. This file retains
cryptographic cheksums of module dependencies, if any. It is used to verify
that cached dependencies meet module requirements.

A module root can reside **anywhere** on the filesystem, whatever is the
current *GOPATH*.

## Module dependencies
Dependencies are downloaded and stored in `GOPATH/src/mod`. A direct
consequence is that the use of a *vendor* directory is now obsolete.

What does this new structure looks like? Suppose we are working on a module
that depends on *github.com/me/lib* at version *1.0.0*. For such a case, in
*GOPATH/src/mod* we would find:

<div class="image-container">
  <image src="/images/module_gopath.png" alt="gopath"/>
</div>

What we can observe is:

- Dependencies source trees are placed at the root of this directory, with a
slight change: the import path is suffixed with `@version`.
- Source archives retrieved or built from VCS are stored in the *download*
folder.
- VCS data is stored in the *vcs* folder.

### Enabling Go modules support
In *Go 1.11beta2*, the environment variable `GO111MODULE` controls whether
module support is enabled or disabled. It accepts three values: `on`, `off`,
`auto` (default).

If set to *"on"*, module support is enabled whatever path we are in.

If set to *"off"*, it is permanently disabled.

If unset or set to *"auto"*, module support is enabled outside of
*GOPATH* only if the current directory is a module root or one of
its subdirectories.


## Integration
Go modules are integrated with Go tools, for instance upon invocation of
commands such as `go build`, `go install`, `go run`, `go test` appropriate
actions will fire up like populating the cache, creating or updating *go.mod*
and *go.sum* etc.

### Autoformat
You should never have to run these commands on your own since they are
invoked by other commands, but for the sake of completeness, let's mention
that `go mod -fmt` is the equivalent of `go fmt` for *go.mod* and *go.sum*
files and that `go mod -fix` do some smart things in order to keep *go.mod*
clean, like:

- Rewriting non-canonical version identifiers to semantic versioning form.
- Removing duplicates.
- Updating requirements to reflect exclusions.


### Initialization
To create *go.mod*:
```
go mod -init
```
You may have to pass the command an import path with `-module <path>` if the
module root lives outside a VCS.

For the sake of backward compatibility and in order to ease the transition
process, module creation has support for popular dependency management tools
like `dep`, `glide`, `glock`, `godep` and so on.

### Synchronization
In order to clean up unused dependencies or to fetch new ones, use the sync
option:

```
go mod -sync
```

### Adding, excluding and replacing dependencies
Two possibilities: either edit *go.mod* by hand or use the CLI. The latter
comes with the following commands:

```bash
# require a new dependency
go mod -require one/thing@version

# drop a requirement
go mod -droprequire one/thing

# exclude a dependency
go mod -exclude bad/thing@version

# drop an exclusion
go mod -dropexclude bad/thing@version

# replace a dependency
go mod -replace src/thing@version=dst/thing@version

# drop a replacement
go mod -dropreplace src/thing@version
```

### Dependency graph
To print the graph of module dependencies:

```
go mod -graph
```

### Generating *vendor*
If for backward compatibility reasons you need to ship your application with
vendoring, you can generate the *vendor* directory from *go.mod* thanks to:

```
go mod -vendor
```

## Getting help
Don't hesistate to refer to `go help mod` and `go help modules` for further
details about Go module support!

[vgo]: https://github.com/golang/vgo
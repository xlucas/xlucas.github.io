---
title: 'Go modules'
teaser: What are Go modules and how to use them.
image: /images/logo.png
comments: true
category: programming
tags: [go]
---

> #### Update
>
> Go 1.11 has been released! A few changes have been introduced and this
> post has been updated accordingly.

## Definition

A module is a collection of related go packages. Modules are the unit of
source code interchange and versionning.

## Quick history

- Go before 1.5: populating _GOPATH_ with `go get`.
- Go 1.5 and after: dependency vendoring is introduced.
- [vgo] is proposed as a prototype for Go modules support.
- Go 1.11: `vgo` is being merged and refined as `go mod`.

## Terminology

This article refers to recurrent expressions. Let's clarify them:

- _"Module root"_: the directory containing the file named `go.mod`.
- _"Module path"_: the import path prefix corresponding to the module root.
- _"Main module"_: the module containing the directory where the `go` command
  is run.

## Module structure

A module is a tree of Go source files to which is added a file named _go.mod_.
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
an import statement is indentified as _indirect_ in the file.

A module can contain other modules, in which case their content is excluded
from the parent module.

<div class="image-container">
  <image src="/images/module_structure.png" alt="structure"/>
</div>

Alongside _go.mod_, a file named `go.sum` may be present. This file retains
cryptographic cheksums of module dependencies, if any. It is used to verify
that cached dependencies meet module requirements.

A module root can reside **anywhere** on the filesystem, whatever is the
current _GOPATH_.

## Module dependencies

Dependencies are downloaded and stored in `GOPATH/pkg/mod`. A direct
consequence is that the use of a _vendor_ directory is now obsolete.

What does this new structure looks like? Suppose we are working on a module
that depends on _github.com/me/lib_ at version _1.0.0_. For such a case, in
_GOPATH/pkg/mod_ we would find:

<div class="image-container">
  <image src="/images/module_gopath.png" alt="gopath"/>
</div>

What we can observe is:

- Dependencies source trees are placed at the root of this directory, with a
  slight change: the import path is suffixed with `@version`.
- Source archives retrieved or built from VCS are stored in the _download_
  folder.
- VCS data is stored in the _vcs_ folder.

### Enabling Go modules support

In _Go 1.11_, the environment variable `GO111MODULE` controls whether
module support is enabled or disabled. It accepts three values: `on`, `off`,
`auto` (default).

If set to _"on"_, mdule support is enabled whatever path we are in.

If set to _"off"_, it is permanently disabled.

If unset or set to _"auto"_, module support is enabled outside of
_GOPATH_ only if the current directory is a module root or one of
its subdirectories.

## Integration

Go modules are integrated with Go tools, for instance upon invocation of
commands such as `go build`, `go get`, `go install`, `go run`, `go test`
appropriate actions will fire up like populating the cache, creating or
updating _go.mod_ and _go.sum_ etc.

### Autoformat

You should never have to run this command on your own since it is invoked by
other commands, but for the sake of completeness, let's mention that `go mod edit -fmt` is the equivalent of `go fmt` for _go.mod_ and _go.sum_.

### Initialization

To create _go.mod_:

```
go mod init <module_path>
```

For the sake of backward compatibility and in order to ease the transition
process, module creation has support for popular dependency management tools
like `dep`, `glide`, `glock`, `godep` and so on.

### Synchronization

In order to clean up unused dependencies or to fetch new ones, use the tidy
option:

```
go mod tidy
```

### Adding, excluding and replacing dependencies

Two possibilities: either edit _go.mod_ by hand or use the CLI. The latter
comes with the following commands:

```bash
# require a new dependency
go mod edit -require one/thing@version

# drop a requirement
go mod edit -droprequire one/thing

# exclude a dependency
go mod edit -exclude bad/thing@version

# drop an exclusion
go mod edit -dropexclude bad/thing@version

# replace a dependency
go mod edit -replace src/thing@version=dst/thing@version

# drop a replacement
go mod edit -dropreplace src/thing@version
```

### Dependency graph

To print the graph of module dependencies:

```
go mod graph
```

### Generating _vendor_

If for backward compatibility reasons you need to ship your application with
vendoring, you can generate the _vendor_ directory from _go.mod_ thanks to:

```
go mod vendor
```

## Getting help

Don't hesistate to refer to `go help mod` and `go help modules` for further
details about Go module support!

[vgo]: https://github.com/golang/vgo

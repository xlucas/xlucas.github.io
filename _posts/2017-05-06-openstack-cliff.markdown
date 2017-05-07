---
layout: post
title: "Building a modern CLI with cliff"
date: 2017-05-06 20:54:00 +0200
comments: true
categories: python
---
## History
Most pythoners probably heard about [Openstack][openstack-org], the famous
open-source software platform for cloud computing. The Openstack ecosystem is
composed of various components, all written in Python. This ensures
interoperability, coherency and accessibility for contributors within the
[Openstack foundation][openstack-foundation]. With mature projects like Nova,
Neutron, Keystone, Swift, Cinder and many others, redundant technical matters
appear. This is the moment one chooses to write a generic solution. From time
to time shiny diamonds are carved out of the former technical issue. Sadly,
some lack visibility and are forgotten.

One of them is [`cliff`][openstack-cliff]. It stands for *Command Line
Interface Formulation Framework*. This is an easy and elegant way to implement
an interactive command line interface in your project. It is used within
Openstack to implement a [unique CLI][github-openstack-client] for all
openstack services (previously each component was respectively implementing its
[own][github-openstack-clients] that's why you will find legacy packages as
`python-novaclient`, `python-swiftclient`, `python-keystoneclient` and so on).
This effort gave birth to a well-designed framework with an interesting set of
features.

I've used it to write a [python CLI][github-confluence-cli] for Confluence and
would like to share key directions to people willing to write elegant command
line interfaces.

## Features

It mainly provides :
- An interactive shell.
- Bash command completion.
- Command suggestion.
- Command result formatting and filtering with support for JSON, CSV, YAML and
  others.

## Philosophy

Using `cliff` is a matter of :
- Declaring a mapping between commands and classes in your package entry
  points.
- Initializing an application that uses a command manager with this mapping.
- Implementing commands by defining argument parsing, defining what action
  should take place and how the action result should be formatted if any.

## Hands-on

We will create a project for a sample application and expose a CLI backed by
cliff.

### Structure

Project structure will be the following:

```
myproject
├── mycli
│   ├── __init__.py
│   ├── commands.py
│   └── shell.py
└── setup.py
```

- In `shell.py` we will define the application entry point and delegate command
line arguments processing to cliff command manager.
- In `commands.py` we will define commands that our CLI will propose to the user.
- In `setup.py` we will declare the cliff dependency as well as each command and
associated class path.

### Dependencies

Obviously `setup.py` should have the following line:

```python
install_requires=['cliff']
```

### Command map

Let's say you want `command` to be handled by the application.  We will define
it as the `Command` class in `commands.py`.

In `setup.py`, add the application main entry point and a
`<command>=<class_path>` mapping bound to a namespace of your choice, for
instance `mycli.cli`:

```python
entry_points={
    'console_scripts': ['mycli=mycli.shell:main'],
    'mycli.cli': [
        'command=mycli.commands:Command',
    ]
```

Subcommand handling is really straightforward, the framework uses underscores
as a convention for command groups. For instance `group_command` will be
exposed as `mycli group command`.

### Entry point

This project now needs a main entry point responsible for running the cliff
application.

```python
import sys

from cliff.app import App
from cliff.commandmanager import CommandManager


def main(arg=sys.argv[1:]):
    app = App(
            description="My Application description",
            version="0.0.1",
            command_manager=CommandManager('mycli.cli'),
            deferred_help=True,
        )
    return app.run(argv)


if __name__ == '__main__':
    sys.exit(main())
```

The namespace passed to the cliff command manager is the one previously
defined in `setup.py`.

### Actions

Implementing a command action is mandatory. It is done through the overriding
of the abstract method `take_action(self, parsed_args)` living in cliff command
base class.

```python
from cliff import command


class Command(command.Command):
    """A basic command."""

    def take_action(self, parsed_args):
        """Command action."""
        return 'Hello World!'
```

### Argument parsing

At this point you have a fully usable CLI with one command available. However,
this is a minimalistic example and you will most likely need to access python's
argument parser. To do so, override the `get_parser(self, prog_name)` method.

We will add two options to print our command result either in lower or upper
case.

```python
from cliff import command


class Command(command.Command):
    """A basic command."""

    def get_parser(self, prog_name):
        """Command argument parsing."""
        parser = super(Command, self).get_parser(prog_name)
        group = parser.add_mutually_exclusive_group()

        group.add_argument(
            '--lowercase',
            help='print result in lower case',
            action='store_true',
        )
        group.add_argument(
            '--uppercase',
            help='print result in upper case',
            action='store_true',
        )

        return parser


    def take_action(self, parsed_args):
        """Command action."""
        result = 'Hello World!'

        # To lower case
        if parsed_args.lowercase:
            return result.lower()

        # To upper case
        if parsed_args.uppercase:
            return result.upper()

        return result
```

### Formatting

If your command returns one or several structured elements, cliff is able to
handle the result and convert it to multiple formats. To leverage this feature
your command class should:
- Inherit from relevant cliff command class (`cliff.show.ShowOne` or
`cliff.lister.Lister`)
- Return data as a `(fields, values)` tuple.

We will now add two new commands to show what it looks like.

```python
entry_points={
    'console_scripts': ['mycli=mycli.shell:main'],
    'mycli.cli': [
        'command=mycli.commands:Command',
        'format_one=mycli.commands:FormatOne',
        'format_many=mycli.commands:FormatMany',
    ]
```

```python
from cliff.lister import Lister
from cliff.show import ShowOne


class FormatOne(ShowOne):
    """A command with one structured item as a result."""

    def take_action(self, parsed_args):
        return ('Field_1', 'Field_2'), ('Value_1', 'Value_2')


class FormatMany(Lister):
    """A command with several structured items as a result."""

    def take_action(self, parsed_args):
        values = (('Value_1', 'Value_2'), ('Value_1', 'Value_3'))
        return ('Field_1', 'Field_2'), values
```

### Result

You can play with it and discover native features by yourself, I will show here
a few of them.

Before anything, install this package with pip:

```
me@home ~/myproject# pip install -e .
```

- Make sure the very first command work as expected:

```
me@home ~/myproject# mycli command --help
usage: mycli command [-h] [--lowercase | --uppercase]

A basic command.

optional arguments:
  -h, --help   show this help message and exit
  --lowercase  print result in lower case
  --uppercase  print result in upper case
```
```
me@home ~/myproject# mycli command
Hello World!
```
```
me@home ~/myproject# mycli command --lowercase
hello world!
```
```
me@home ~/myproject# mycli command --uppercase
HELLO WORLD!
```

- Experiment with command output formats:

```
me@home ~/myproject# mycli format --help
Command "format" matches:
  format many
  format one
```
```
me@home ~/myproject# mycli format one
+---------+---------+
| Field   | Value   |
+---------+---------+
| Field_1 | Value_1 |
| Field_2 | Value_2 |
+---------+---------+
```
```
me@home ~/myproject# mycli format one -f json
{
  "Field_2": "Value_2",
  "Field_1": "Value_1"
}
```
```
me@home ~/myproject# mycli format many
+---------+---------+
| Field_1 | Field_2 |
+---------+---------+
| Value_1 | Value_2 |
| Value_1 | Value_3 |
+---------+---------+
```
```
me@home ~/myproject# mycli format many -f yaml
- Field_1: Value_1
  Field_2: Value_2
- Field_1: Value_1
  Field_2: Value_3
```

- Let's take a look at the interactive shell:

```
me@home ~/myproject# mycli
(mycli) help

Shell commands (type help <topic>):
===================================
cmdenvironment  eof   history  load   py    run   set    shortcuts
edit            help  list     pause  quit  save  shell  show

Application commands (type help <topic>):
=========================================
command  complete  format many  format one  help
```

- What about command suggestion ?

```
me@home ~/myproject# mycli kommand
mycli: 'kommand' is not a mycli command. See 'mycli --help'.
Did you mean one of these?
  command
```

[openstack-org]: https://www.openstack.org/
[openstack-cliff]: https://github.com/openstack/cliff
[openstack-foundation]: https://www.openstack.org/foundation
[openstack-components]: https://www.openstack.org/software/project-navigator
[github-confluence-cli]: https://github.com/xlucas/confluence-python-cli
[github-openstack-client]: https://github.com/openstack?utf8=%E2%9C%93&q=client
[github-openstack-clients]: https://github.com/openstack/python-openstackclient

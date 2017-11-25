########
ShellDoc
########

.. contents::

Overview
========

ShellDoc is a tool for generating reStructuredText_ formatted documentation
from shell scripts, or any programming language that uses the ``#`` symbol
to denote comments. This generally makes it useful as a documentation generator
for languages that do not have documentation generators.

While any language using ``#`` as a comment character can be used with
ShellDoc, keep in mind that it is specifically tailored for shell scripting
languages in the `sh` family.

ShellDoc is loosely inspired by the PowerShell documentation format, and
is written in Python 3. ShellDoc has no dependencies beyond the Python 3
standard library.

Key Features
------------

* Language-agnostic; ShellDoc does not attempt to parse or understand the
  documented source code at all - only lines that begin with `#` are even
  considered by ShellDoc.

* Standalone `.rst` output can be used with Sphinx, or with `rst2pdf`.

* Documentation syntax is human-readable, and every easy to learn.

* Stream-oriented, single-pass design make ShellDoc safe to use in
  pipelines.

  + **HINT**: use ``--input=/dev/stdin`` to accept input from pipes.


How to Document Scripts with ShellDoc
=====================================

ShellDoc understands two types of documentation: documentation for scripts, and
documentation for functions. Either or both can be present in a single input
file. Documentation is broken into logical *segments*, which are further broken
down into *sections*.

Script-level documentation begins with the following line (*segment opening*)::

        # .SCRIPTDOC

Function-level documentation begins with the following line (*segment
opening*)::

        # .DOCUMENTS functionname

Both types of segments end with::

        # .ENDOC

All commented lines in the input between a segment opening and it's associated
``.ENDOC`` constitute a *segment*.

Note that all leading whitespace to the ``#`` symbol, the ``#``, and the
**first** character after it are stripped. For example, consider this input::

        # some text
        #   some more text
        #one more line of text

This would produce the output::

        some text
          some more text
        ne more line of text

Within a *segment*, there are a number of valid *sections*. Sections begin
with a line of the format::

        # .SECTION_TYPE

And end either at ``.ENDOC`` or when the next section begins.

The following section types are valid for script-level segments:

* ``.DESCRIPTION``
* ``.SYNTAX``
* ``.LICENSE``
* ``.CHANGELOG``
* ``.AUTHOR``

The following section types are valid for function-level segments:

* ``.DESCRIPTION``
* ``.SYNTAX``


Aside from segment openings, ``.ENDOC`` statements, and section openings, all
other lines of input that begin with ``#`` and are part of a segment/section
are passed through unmodified (except for leading and trailing whitespace being
stripped).

Note that empty commented lines are preserved, for example::

        # some words
        #
        #
        #


results in the output ``some words`` followed by 3 blank lines.

Runs of empty lines (containing only whitespace) imply a single blank line
in the output. For example::

        # paragraph 1
        #
        # paragraph 2

Would result in the output::

        paragraph 1

        paragraph 2

The ``.SYNTAX`` Section
-----------------------

All sections except for ``.SYNTAX`` are passed directly through to the output
without modification, the Syntax section is a bit different. Namely, it is
rendered as a reStructuredText pre-formatted code block (i.e. it is preceded by
a ``::``, and each line in the Syntax section is indented by four spaces).

This design decision was made because there are many common plain-text styles
and formats that do not translate well to reST.


ShellDoc Usage
--------------

::


        usage: shelldoc [-h] --input INPUT [--output OUTPUT] [--doctitle DOCTITLE]
                        [--notoc] [--notitle]

        A tool for document shell scripts

        optional arguments:
          -h, --help            show this help message and exit
          --input INPUT, -i INPUT
                                Input file to process
          --output OUTPUT, -o OUTPUT
                                Output file for generated documentation, stdout by
                                default.
          --doctitle DOCTITLE, -t DOCTITLE
                                Set document title, default is input filename
          --notoc, -n           Do not include ..contents:: in output
          --notitle, -e         Do not include the document title in output

Examples
--------

Please see the examples_ folder.

.. _reStructuredText: http://docutils.sourceforge.net/rst.html#user-documentation
.. _examples: ./examples/

Roadmap
=======

While ShellDoc is sufficiently complete to be useful, there are a number of
features that could be added to improve it, some that come to mind include:

* Some better syntax to handle the functionality of ``.SYNTAX``.
* Break out ``shelldoc`` into more modular components.
  + Add switches to extract individual segments and sections.
  + Build a library/API other Python code can use to extract individual segments and sections.
  + Add unit tests for each component.
* Add end-to-end smoke testing.

Contribution
============

Contributions in the form of suggestions, bug reports, documentation, and/or
source code are gratefully accepted.

License
=======

See the LICENSE_ file.

.. _LICENSE: ./LICENSE

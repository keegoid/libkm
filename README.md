libkm
=====

A collection of useful shell functions for use in scripting projects.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Overview](#overview)
- [Usage](#usage)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Overview

As my work with [shell scripts][ss] progresses, I've noticed an increase in repeated code blocks. More and more I'm having to keep the same code updated in several places. The solution, centralize duplicate code into one or more [library files][lf].

Spending a little time converting duplicate code into functions isn't too hard, plus it can improve the readability and reliability of more complex projects. Large chunks of logic can be hidden away and called upon as often as necessary. All that's required is to source the library file in any scripts that need it.

## Usage

This is an example of how to source a library file in your [shell script][ss]:

```bash
# source the library file
source includes/base.lib
# can also use the dot notation
. includes/base.lib
```

## License

SEE: http://keegoid.mit-license.org


[centos]:   http://centos.org/
[ss]:       http://en.wikipedia.org/wiki/Shell_script
[lf]:       http://bash.cyberciti.biz/guide/Shell_functions_library

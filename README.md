libkm
=====

A collection of useful shell functions for use in various [CentOS][centos] scripting projects.

Overview:

As my work with [shell scripts][ss] progresses, I've noticed an increase in repeated code blocks. More and more I'm having to keep the same code updated in several places. The solution, centralize duplicate code into one or more [library files][lf].

Spending a little time converting duplicate code into functions isn't too hard, plus it can improve the readability and reliability of more complex projects. Large chunks of logic can be hidden away and called upon as often as necessary. All that's required is to source the library file in any scripts that need it.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Usage](#usage)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Usage

This is an example of how to source a library file in your [shell script][ss]:

```bash
#!/bin/bash
echo "*********************************************"
echo "* An example shell script with sourced       "
echo "* library file.                              "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# source the library file
source include/base.lib
# can also use the dot notation
. include/git.lib

# calling a function from the library to check for root user permissions
is_root && echo "root user detected, continuing..." || echo "please run this script as root user"

# get name of this script and print messages before and after the name
script_name "done with " ", next run sync.sh"
```

## License

Author : Keegan Mullaney  
Company: KM Authorized LLC  
Website: http://kmauthorized.com

MIT: http://kma.mit-license.org


[centos]:   http://centos.org/
[ss]:       http://en.wikipedia.org/wiki/Shell_script
[lf]:       http://bash.cyberciti.biz/guide/Shell_functions_library

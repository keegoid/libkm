#!/bin/bash
echo "# --------------------------------------------"
echo "# A script to sync library files included in  "
echo "# various scripting projects using rsync      "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

LIB_DIR='includes'
PROJECTS='ubuntu-quick-config'

source lib/base.lib

read -p "Press enter to sync shell librarys to projects..."
for proj in $PROJECTS; do
   echo "$proj"
   rsync -vrupE --exclude "*.*~" "lib/" "../$proj/$LIB_DIR"
done

echo
script_name "done with "

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
PROJECTS='ubuntu-workstation-setup'
#PROJECTS='linux-deploy-scripts middleman-html5-foundation/setup'

source lib/base.lib

read -p "Press enter to sync shell librarys..."
for proj in $PROJECTS; do
   echo "$proj"
   rsync -vrupE "lib/" "../$proj/$LIB_DIR"
done

echo
script_name "done with "

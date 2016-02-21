#!/bin/bash
echo "# --------------------------------------------"
echo "# A script to sync library files included in  "
echo "# various scripting projects using rsync      "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Company: KM Authorized LLC                  "
echo "# Website: http://kmauthorized.com            "
echo "#                                             "
echo "# MIT: http://kma.mit-license.org             "
echo "# --------------------------------------------"

LIB_DIR='includes'
PROJECTS='linux-deploy-scripts'
#PROJECTS='linux-deploy-scripts2 middleman-html5-foundation/setup'

source lib/base.lib

read -p "Press enter to sync shell librarys..."
for proj in $PROJECTS; do
   echo "$proj"
   rsync -vrupE "lib/" "../$proj/$LIB_DIR"
done

echo
script_name "done with "

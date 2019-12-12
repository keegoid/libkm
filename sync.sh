#!/bin/bash
echo "# --------------------------------------------"
echo "# A script to sync library files included in  "
echo "# various scripting projects using rsync      "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website:                                    "
echo "# Email  : keegan@kmauthorized.com            "
echo "# License: MIT                                "
echo "# --------------------------------------------"

# LIBS_DIR=''
# projects must be in the same directory as libkm
PROJECTS='qc'

read -rp "Press enter to sync shell librarys to projects..."
for proj in $PROJECTS; do
    echo "$proj"
#    rsync -vrupE --exclude "*.*~" "lib/" "../$proj/$LIBS_DIR"
    rsync -vupE "colors.sh" "../$proj"
    rsync -vupE "libkm.sh" "../$proj"
done
echo "done with sync"

#!/bin/bash
echo "*********************************************"
echo "* A script to sync library files included in "
echo "* various scripting projects using rsync     "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

LIB='lib'

source $LIB/_km.lib

read -p "Press enter to sync shell librarys..."
rsync -vrupE $LIB/ ../linux-deploy-scripts/includes
rsync -vrupE $LIB/ ../base-middleman-html5-foundation/includes

echo
script_name "done with "

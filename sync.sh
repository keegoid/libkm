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

source lib/libkm.sh

read -p "Press enter to sync shell librarys..."
rsync -vrupE lib/ ../linux-deploy-scripts/includes
rsync -vrupE lib/ ../base-middleman-html5-foundation/includes

echo
script_name "done with "

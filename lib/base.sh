#!/bin/bash
# --------------------------------------------
# A library of useful Linux functions
#
# Author : Keegan Mullaney
# Website: http://keegoid.com
# Email  : keeganmullaney@gmail.com
#
# http://keegoid.mit-license.org
# --------------------------------------------

# note: true=0 and false=1 in bash

# purpose: converts a string to lower case
# arguments:
#   $1 -> string to convert to lower case
function to_lower() 
{
    local str="$@"
    local output     
    output=$(tr '[A-Z]' '[a-z]'<<<"${str}")
    echo $output
}

# purpose: to display an error message and die
# arguments:
#   $1 -> message
#   $2 -> exit status (optional)
function die() 
{
    local m=$1 	   # message
    local e=${2-1}	# default exit status 1
    printf "$m"
    exit $e
}

# purpose: return true if script is executed by the root user
# arguments: none
# return: true or die with message
function is_root() 
{
#   [ $(id -u) -eq 0 ] && echo true || echo false
   [ "$EUID" -eq 0 ] && echo true || echo false
}
 
# purpose: return true if $user exits in /etc/passwd
# arguments:
#   $1 -> username to check in /etc/passwd
# return: true or false
function user_exists()
{
   local u="$1"
   # -q (quiet), -w (only match whole words, otherwise "user" would match "user1" and "user2")
   if grep -qw "^${u}" /etc/passwd; then
      #echo "user $u exists in /etc/passwd"
      echo true
   else
      #echo "user $u does not exists in /etc/passwd"
      echo false
   fi
}

# purpose: prompt user with binary option
# arguments:
#   $1 -> text string to prompt user
#   #2 -> default to no? (optional)
# return: true or false
function confirm()
{
   local text="$1"
   local preferNo="$2"

   # check preference
   if [ -n "${preferNo}" ] && [ "${preferNo}" = false ]; then
      # prompt user with preference for Yes
      read -rp "${text} [Y/n] " response
      case $response in
         [nN][oO]|[nN])
            echo false
            ;;
         *)
            echo true
            ;;
      esac
   else
      # prompt user with preference for No
      read -rp "${text} [y/N] " response
      case $response in
         [yY][eE][sS]|[yY]) 
            echo true
            ;;
         *) 
            echo false
            ;;
      esac
   fi
}

# purpose: trim shortest pattern from the left
# arguments:
#   $1 -> variable
#   $2 -> pattern
function trim_shortest_left_pattern()
{
   echo -n "${1#*$2}"
   # -n (don't create newline character)
}

# purpose: trim longest pattern from the left
# arguments:
#   $1 -> variable
#   $2 -> pattern
function trim_longest_left_pattern()
{
   echo -n "${1##*$2}"
}

# purpose: trim shortest pattern from the right
# arguments:
#   $1 -> variable
#   $2 -> pattern
function trim_shortest_right_pattern()
{
   echo -n "${1%$2*}"
}

# purpose: trim longest pattern from the right
# arguments:
#   $1 -> variable
#   $2 -> pattern
function trim_longest_right_pattern()
{
   echo -n "${1%%$2*}"
}

# purpose: return name of script being run
# arguments:
#   $1 -> message before
#   $2 -> message after
function script_name()
{
#   echo "$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

   # can be accomplished with trim_longest_left_pattern instead
   echo -n "$1" && trim_longest_left_pattern $0 / && echo "$2"
}

# purpose: wait for user to press enter
# arguments:
#   $1 -> user message
function pause()
{
  local msg="$1"
  [ -z "${msg}" ] && msg="Press [Enter] key to continue..."
  read -p "$msg"
}

# purpose: run a script from another script
# arguments:
#   $1 -> name of script to be run
function run_script()
{
   local script="$1"
   local project_dir="$PWD"
   # reset back to root poject directory to run scripts
   cd "$project_dir/scripts"
#   echo "changing directory to $_"
   # make sure dos2unix is installed
   [ -n "$(apt-cache policy dos2unix | grep 'Installed: (none)')" ] && { echo >&2 "dos2unix will be installed."; sudo apt-get -y install dos2unix; }
   dos2unix -k -q ${script}
   chmod +x ${script}
#   sudo chown $(logname):$(logname) ${script} && echo "owner set to $(logname)"
   read -p "Press enter to run: ${script}"
   . ./${script}
   echo
   echo "          done with ${script}"
   echo "*********************************************"
   cd "$project_dir"
}

# purpose: set Repos directory location
# arguments:
#   $1 -> non-root Linux username
#   $2 -> use Dropbox?
function locate_repos()
{
   local u="$1"
   local db=$2
   local repos

   if [ "$db" = true ]; then
      repos="/home/${u}/Dropbox/Repos"
      # if dropbox directory is made, set ownership
      if mkdir -p "/home/${u}/Dropbox"; then
         chown $u:$u "/home/${u}/Dropbox"
      fi
   else
      repos="/home/${u}/Repos"
   fi

   # if repos directory is made, set ownership
   mkdir -p "$repos"
#   if mkdir -p "$repos"; then
#      chown $u:$u "$repos"
#   fi
   echo -n $repos
}

# purpose: generate an RSA SSH keypair if none exists or copy from root
# arguments:
#   $1 -> SSH directory
#   $2 -> SSH key comment
#   $3 -> use SSH?
#   $4 -> non-root Linux username
function gen_ssh_keys()
{
   local ssh_dir="$1"
   local comment="$2"
   local use_ssh=$3
   local u="$4"

#   echo "variable use_ssh = $use_ssh"
#   pause

   if [ "$use_ssh" = true ]; then
      # move id_rsa to new user account or create new SSH keypair if none exists
      echo
      echo "Note: ${ssh_dir}/id_rsa is for public/private key pairs to establish"
      echo "outgoing SSH connections to remote systems"
      echo

      # check if id_rsa already exists and skip if true
      if [ -e "${ssh_dir}/id_rsa" ]; then
         echo "${ssh_dir}/id_rsa already exists"
      # if it doesn't exist, get it from root user
#      elif [ -e "$HOME/.ssh/id_rsa" ] && [ -n "${u}" ]; then
#         mkdir -pv "${ssh_dir}"
#         cp -v $HOME/.ssh/id_rsa ${ssh_dir}
#         cp -v $HOME/.ssh/id_rsa.pub ${ssh_dir}
#         chmod -c 0600 "${ssh_dir}/id_rsa"
#         chown -cR "${u}":"${u}" "${ssh_dir}"
      # if no id_rsa, create a new keypair
      else
         # create a new ssh key with provided ssh key comment
         echo "create new key: ${ssh_dir}/id_rsa"
         pause "Press enter to generate a new SSH key"
         ssh-keygen -b 4096 -t rsa -C "${comment}"
         echo "SSH key generated"
#         if [ -e "$HOME/.ssh/id_rsa" ] && [ -n "${ssh_dir}/id_rsa" ]; then
#            mkdir -pv "${ssh_dir}"
#            cp -v $HOME/.ssh/id_rsa "${ssh_dir}/id_rsa"
#            cp -v $HOME/.ssh/id_rsa.pub "${ssh_dir}/id_rsa.pub"
#         fi
	      chmod -c 0600 "${ssh_dir}/id_rsa"
         chown -cR "${u}":"${u}" "${ssh_dir}"
         echo
         echo "*** NOTE ***"
         echo "Copy the contents of id_rsa.pub (printed below) to the SSH keys section"
         echo "of your GitHub account or authorized_keys section of your remote server."
         echo "Highlight the text with your mouse and press ctrl+shift+c to copy."
         echo
         cat "${ssh_dir}/id_rsa.pub"
         echo
         read -p "Press enter to continue..."
      fi
      echo
      echo "Have you copied id_rsa.pub (above) to the SSH keys section"
      echo "of your GitHub account?"
      select yn in "Yes" "No"; do
         case $yn in
            "Yes") break;;
             "No") echo "Copy the contents of id_rsa.pub (printed below) to the SSH keys section"
                   echo "of your GitHub account."
                   echo "Highlight the text with your mouse and press ctrl+shift+c to copy."
                   echo
                   cat "${ssh_dir}/id_rsa.pub";;
                *) echo "case not found, try again..."
                   continue;;
         esac
         break
      done
   fi
}

# purpose: set authorized SSH keys for incoming connections on remote host
# arguments:
#   $1 -> SSH directory
#   $2 -> non-root Linux username
function authorized_ssh_keys()
{
   local ssh_dir="$1"
   local u="$2"
   local ssh_rsa

   echo
   echo "Note: ${ssh_dir}/authorized_keys are public keys to establish"
   echo "incoming SSH connections to a server"
   echo
   if [ -e "${ssh_dir}/authorized_keys" ]; then
      echo "${ssh_dir}/authorized_keys already exists for ${u}"
   else
#      passwd "${u}"
#      echo
#      echo "for su root command:"
#      passwd root # for su root command
      mkdir -pv "${ssh_dir}"
      chmod -c 0700 "${ssh_dir}"
      echo
      echo "*** NOTE ***"
      echo "Paste (using ctrl+shift+v) your public ssh-rsa key from your workstation"
      echo "to SSH into this server."
      read -ep "Paste it here: " ssh_rsa
      echo "${ssh_rsa}" > "${ssh_dir}/authorized_keys"
      echo "public SSH key saved to ${ssh_dir}/authorized_keys"
      chmod -c 0600 "${ssh_dir}/authorized_keys"
      chown -cR "${u}":"${u}" "${ssh_dir}"
   fi
}

# purpose: import public GPG key if it doesn't already exist in list of RPM keys
#          although rpm --import won't import duplicate keys, this is a proof of concept
# arguments:
#   $1 -> URL of the public key file
# return: false if URL is empty, else true
function get_public_key()
{
   local url="$1"
   local apt_keys="$HOME/apt_keys"

   [ -z "${url}" ] && echo false && return
   pause "Press enter to download and import the GPG Key..."
   mkdir -pv "$apt_keys"
   cd "$apt_keys"
#   echo "changing directory to $_"
   # download keyfile
   wget -nc "$url"
   local key_file=$(trim_longest_left_pattern "${url}" /)
   # get key id
   local key_id=$(echo $(gpg --throw-keyids < "$key_file") | cut --characters=11-18 | tr [A-Z] [a-z])
   # import key if it doesn't exist
   if ! apt-key list | grep "$key_id" > /dev/null 2>&1; then
      echo "Installing GPG public key with ID $key_id from $key_file..."
      sudo apt-key add "$key_file"
   fi
   # change directory back to previous one
   echo -n "changing directory back to " && cd -
}

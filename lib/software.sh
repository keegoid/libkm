#!/bin/bash
# --------------------------------------------
# A library of functions to set repository
# and software versions, download and
# install repositories and apps
#
# Author : Keegan Mullaney
# Website: http://keegoid.com
# Email  : keeganmullaney@gmail.com
#
# http://keegoid.mit-license.org
# --------------------------------------------

# names and versions of repositories/software
SN=( EPEL   REMI   NGINX   OPENSSL   ZLIB   PCRE   FRICKLE   RUBY  )
SV=( 7-5    7      1.9.9   1.0.2f    1.2.8  8.38   2.3       2.3.0 )

# URLs to check software versions for latest versions
#    EPEL   dl.fedoraproject.org/pub/epel/7/x86_64/e/
#    REMI   rpms.famillecollet.com/enterprise/
#   NGINX   nginx.org/download/
# OPENSSL   www.openssl.org/source/
#    ZLIB   zlib.net/
#    PCRE   http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/
# FRICKLE   https://github.com/FRiCKLE/ngx_cache_purge/
#    RUBY   www.ruby-lang.org/en/downloads/

# purpose: set software versions
# arguments:
#   $1 -> software list (space-separated)
function set_software_versions()
{
   local swl="$1"
   local version
   echo
   for ((i=0; i<${#SN[@]}; i++)); do
      if echo $swl | grep -qw "${SN[i]}"; then
         read -ep "Enter software version for ${SN[i]}: " -i "${SV[i]}" version
         SV[i]="$version"
      fi
   done
}

# version variable assignments (determined by array order)
EPEL_V="${SV[0]}"
REMI_V="${SV[1]}"
NGINX_V="${SV[2]}"
OPENSSL_V="${SV[3]}"
ZLIB_V="${SV[4]}"
PCRE_V="${SV[5]}"
FRICKLE_V="${SV[6]}"
RUBY_V="${SV[7]}"

# software download URLs
EPEL_URL="http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-${EPEL_V}.noarch.rpm"
REMI_URL="http://rpms.famillecollet.com/enterprise/remi-release-${REMI_V}.rpm"
NGINX_URL="http://nginx.org/download/nginx-${NGINX_V}.tar.gz"
OPENSSL_URL="http://www.openssl.org/source/openssl-${OPENSSL_V}.tar.gz"
ZLIB_URL="http://zlib.net/zlib-${ZLIB_V}.tar.gz"
PCRE_URL="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_V}.tar.gz"
FRICKLE_URL="https://github.com/FRiCKLE/ngx_cache_purge/archive/master.zip"
RUBY_URL="https://get.rvm.io"
WORDPRESS_URL="http://wordpress.org/latest.tar.gz"

# GPG public keys
EPEL_KEY="http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-"$(trim_longest_right_pattern "${EPEL_V}" -)
REMI_KEY='http://rpms.famillecollet.com/RPM-GPG-KEY-remi'

# purpose: download and extract software
# arguments:
#   $1 -> list of URLs to software (space-separated)
function get_software()
{
   local list="$1"
   local name

   echo
   for url in ${list}; do
      name="${url##*/}"
      read -p "Press enter to download and extract: $name"
      wget -nc $url
      tar -xzf $name
   done
}

# purpose: to check if program is NOT installed
# arguments:
#   $1 -> program name
# returns: true if not installed, false if installed or unrecognized program name
function not_installed()
{
   local app="$1"
   [ -n "$(apt-cache policy ${app} | grep 'Installed: (none)')" ] && echo true || echo false
}

# purpose: to install programs from a list
# arguments:
#   $1 -> program list (space-separated)
#   $2 -> enable-repo (optional)
function install_apt()
{
   local names="$1"
   local repo="$2"
   # install applications in the list
   for apt in $names; do
      if [ "$(not_installed $apt)" = true ]; then
         echo
         read -p "Press enter to install $apt..."
         [ -z "${repo}" ] && sudo apt-get -y install "$apt" || { sudo apt-add-repository "${repo}"; sudo apt-get update; sudo apt-get -y install "$apt"; }
      fi
   done
}

# purpose: to install npm packages from a list
# arguments:
#   $1 -> npm list (space-separated)
function install_npm()
{
   local names="$1"
   # make sure npm is installed
   install_apt "npm"
   # symlink nodejs to path
   if [ ! -L /usr/bin/node ]; then
      sudo ln -s "$(which nodejs)" /usr/bin/node
   fi
   # install npm packages in the list
   for app in $names; do
      if ! npm ls -gs | grep -qw "$app"; then
         echo
         read -p "Press enter to install $app..."
         sudo npm install -g "$app"
      fi
   done
}

# purpose: to install gems from a list
# arguments:
#   $1 -> gem list (space-separated)
function install_gem()
{
   local names="$1"
   # make sure ruby and rubygems are installed
   install_apt "ruby rubygems"
   # install gems in the list
   for app in $names; do
      if ! $(gem list "$app" -i); then
         echo
         read -p "Press enter to install $app..."
         gem install "$app"
      fi
   done
}

# purpose: to install pips from a list
# arguments:
#   $1 -> pip list (space-separated)
function install_pip()
{
   local names="$1"
   # make sure python-pip and python-gpgme are installed
   install_apt "python-pip python-gpgme"
   # install pips in the list
   for app in $names; do
      app=$(trim_longest_right_pattern "$app" "[")
      if ! pip list | grep "$app" >/dev/null 2>&1; then
         echo
         read -p "Press enter to install $app..."
         sudo pip install "$app"
      fi
   done
}

# purpose: to install ruby and rubygems
# arguments: none
function install_ruby()
{
   echo
   read -p "Press enter to install ruby and rubygems..."
   if ! ruby -v | grep -q "ruby ${RUBY_V}"; then
      gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
      curl -L "$RUBY_URL" | bash -s stable --ruby="${RUBY_V}"
   fi
}

# purpose: to source the rvm command
# arguments: none
function source_rvm()
{
   echo
   read -p "Press enter to start using rvm..."
   if grep -q "/usr/local/rvm/scripts/rvm" $HOME/.bashrc; then
      source /usr/local/rvm/scripts/rvm && echo "sourced rvm"
   else
      echo "source /usr/local/rvm/scripts/rvm" >> $HOME/.bashrc
      source /usr/local/rvm/scripts/rvm && echo "rvm sourced and added to .bashrc"
   fi
}

# purpose: to install keybase
function install_keybase()
{
   if [ "$(not_installed keybase)" = true ]; then
      # change to tmp directory to download file and then back to original directory
      cd /tmp
      curl -O https://dist.keybase.io/linux/deb/keybase-latest-amd64.deb && sudo dpkg -i keybase-latest-amd64.deb
      cd - >/dev/null
   fi
}

# purpose: to install newer version of virtualbox per VVV requirements
function install_virtualbox()
{
   if [ "$(not_installed virtualbox-5.0)" = true ]; then
      # add virtualbox to sources list if not already there
      if ! grep -q "virtualbox" /etc/apt/sources.list; then
         echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" | sudo tee --append /etc/apt/sources.list
      fi
      # add signing key
      wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
      # update sources and install the latest virtualbox
      sudo apt-get update
      install_apt "virtualbox-5.0"
   fi
}

# purpose: to install newer version of vagrant per VVV requirements
function install_vagrant()
{
   if [ "$(not_installed vagrant)" = true ]; then
      # change to tmp directory to download file and then back to original directory
      cd /tmp
      echo "downloading vagrant..."
      curl -O https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb && sudo dpkg -i vagrant_1.8.1_x86_64.deb
      cd - >/dev/null
   fi
   # install vagrant-hostsupdater
   [ -z "$(vagrant plugin list | grep hostsupdater)" ] && echo "${LIGHT_GRAY} NOTE: a vpn may be required in China for this... ${STD}" && vagrant plugin install vagrant-hostsupdater
   # install vagrant-triggers
   [ -z "$(vagrant plugin list | grep triggers)" ] && echo "${LIGHT_GRAY} NOTE: a vpn may be required in China for this... ${STD}" && vagrant plugin install vagrant-triggers
}

# purpose: to clone vvv
# arguments:
#   $1 -> repos directory
function clone_vvv()
{
   local repos="$1"
   if ! [ -d "${repos}/vagrants/vvv" ]; then
      # clone VVV to vagrants directory
      git clone https://github.com/Varying-Vagrant-Vagrants/VVV.git "${repos}/vagrants/vvv"
      echo "use \'vagrant up\' to start VVV from within ${repos}/vagrants/vvv"
   fi
}

# purpose: to clone vv
# arguments:
#   $1 -> repos directory
function clone_vv()
{
   local repos="$1"
   if ! [ -d "${repos}/vv" ]; then
      # clone VV to vv directory
      git clone https://github.com/bradp/vv.git "${repos}/vv"
      # add vv directory to PATH
      if ! grep -q "${repos}/vv" $HOME/.profile; then
         echo "PATH=${repos}/vv:$PATH" >> $HOME/.profile
         echo "vv directory added to PATH so vv commands will work in terminal"
      fi
   fi
}

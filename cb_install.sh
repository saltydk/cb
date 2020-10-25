#!/bin/bash
#########################################################################
# Title:         Cloudbox Install Script                                #
# Author(s):     desimaniac                                             #
# URL:           https://github.com/cloudbox/cb                         #
# --                                                                    #
#         Part of the Cloudbox project: https://cloudbox.works          #
#########################################################################
#                   GNU General Public License v3.0                     #
#########################################################################

################################
# Variables
################################

VERBOSE=false
VERBOSE_OPT=""
CB_REPO="https://github.com/saltydk/cb.git"
CB_PATH="/srv/git/cb"
CB_INSTALL_SCRIPT="$CB_PATH/cb_install.sh"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

################################
# Functions
################################

run_cmd () {
  if $VERBOSE; then
      printf '%s\n' "+ $*" >&2;
      "$@"
  else
      "$@" > /dev/null 2>&1
  fi
}

################################
# Argument Parser
################################

while getopts 'v' f; do
  case $f in
  v)  VERBOSE=true
      VERBOSE_OPT="-v"
  ;;
  esac
done

################################
# Main
################################

$VERBOSE || exec &>/dev/null

$VERBOSE && echo "Script Path: " $SCRIPT_PATH

# Install git
run_cmd apt-get install -y git

# Remove existing repo folder
if [ -d "$CB_PATH" ]; then
    run_cmd rm -rf $CB_PATH;
fi

# Clone CB repo
run_cmd mkdir -p /srv/git
run_cmd git clone --branch develop "${CB_REPO}" "$CB_PATH"

# Set chmod +x on script files
run_cmd chmod +x $CB_PATH/*.sh

$VERBOSE && echo "Script Path: "$SCRIPT_PATH
$VERBOSE && echo "CB Install Path: "$CB_INSTALL_SCRIPT

## Create script symlinks in /usr/local/bin
shopt -s nullglob
for i in "$CB_PATH"/*.sh; do
    if [ ! -f "/usr/local/bin/$(basename "${i%.*}")" ]; then
        run_cmd ln -s "${i}" "/usr/local/bin/$(basename "${i%.*}")"
    fi
done
shopt -u nullglob

# Relaunch script from new location
if [ "$SCRIPT_PATH" != "$CB_INSTALL_SCRIPT" ]; then
    bash -H "$CB_INSTALL_SCRIPT" "$@"
    exit $?
fi

# Install Cloudbox Dependencies
run_cmd bash -H $CB_PATH/cb_dep.sh $VERBOSE_OPT

# Clone Cloudbox Repo
run_cmd bash -H $CB_PATH/cb_repo.sh -b develop $VERBOSE_OPT

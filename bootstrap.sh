#!/bin/sh
# Copyright (c) 2022, SENAI Cimatec
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

PWD=$(pwd)
AUTOPROJ_VERSION=""
MANIFEST_FILE=${PWD}/autoproj
BOOTSTRAP_BRANCH=main
BOOTSTRAP_MANIFEST=manifest
AUTOPROJ_INSTALL_URL=https://raw.githubusercontent.com/rock-core/autoproj/master/bin/autoproj_install

# BOOTSTRAP_URL=git@github.com:Brazilian-Institute-of-Robotics/bir.botanic-grasping-buildconf.git
BOOTSTRAP_URL=git@github.com:deividG0/bir.botanic_grasping-buildconf.git
PYTHON_EXECUTABLE=/usr/bin/python3

export AUTOPROJ_OSDEPS_MODE=all
export AUTOPROJ_BOOTSTRAP_IGNORE_NONEMPTY_DIR=1

[ -f "autoproj_install" ] || wget -nv ${AUTOPROJ_INSTALL_URL}
[ -d ".autoproj" ] || { mkdir -p .autoproj; cat <<EOF > .autoproj/config.yml; }
---
apt_dpkg_update: true
osdeps_mode: all
GITORIOUS: ssh
GITHUB: ssh
GITHUB_ROOT: 'git@github.com:'
GITHUB_PUSH_ROOT: 'git@github.com:'
GITHUB_PRIVATE_ROOT: 'git@github.com:'
GITORIOUS_ROOT: 'git@gitorious.org:'
GITORIOUS_PUSH_ROOT: 'git@gitorious.org:'
GITORIOUS_PRIVATE_ROOT: 'git@gitorious.org:'
CODE_INTEGRATION: true
CODE_MANAGE_FOLDERS: false
USE_PYTHON: true
python_executable: "${PYTHON_EXECUTABLE}"
ros_version: 2
ros_distro: 'humble'
user_shells:
- bash
EOF

cat <<EOF > autoproj.gemfile
source "https://rubygems.org"
gem "autoproj", github: 'rock-core/autoproj'
gem "autobuild", github: 'rock-core/autobuild'
EOF

usage() {
    printf "\nUsage: $0 [options] [manifest]"
    printf "\n\nOptions:"
    printf "\n\t-m|--manifest Set the default manifest"
    printf "\n\t-b|--branch Set the default branch"
    printf "\n\t-v|--version Set autoproj version"
    printf "\n\t-p|--project Set the project name\n\n"
    printf "\n\t-h|--help Shows this help message\n\n"
    exit 1
}

while getopts "m:b:v:h" OPT; do
    case "${OPT}" in
        "m") BOOTSTRAP_MANIFEST=${OPTARG};;
        "b") BOOTSTRAP_BRANCH=${OPTARG};;
        "v") AUTOPROJ_VERSION=${OPTARG};;
        "p") BOOTSTRAP_URL=${OPTARG};;
        "h") usage;;
        "?") exit 1;;
    esac
done

if [ -z "$AUTOPROJ_VERSION" ]; then
    ruby autoproj_install --gemfile=autoproj.gemfile
    else
    ruby autoproj_install --version=${AUTOPROJ_VERSION}  
fi

. ./env.sh

autoproj bootstrap git ${BOOTSTRAP_URL} branch=${BOOTSTRAP_BRANCH}

printf -- " -- $0 environment...\n"
printf -- " -- $(eval autoproj version)\n"
printf -- " -- manifest -m ${BOOTSTRAP_MANIFEST}\n"
printf -- " -- branch   -b ${BOOTSTRAP_BRANCH}\n"
printf -- " -- Search for ${MANIFEST_FILE}/${BOOTSTRAP_MANIFEST}\n"
printf -- " -- Path to python executable ${PYTHON_EXECUTABLE}\n"

if [ -f ${MANIFEST_FILE}/${BOOTSTRAP_MANIFEST} ]; then
    AUTOPROJ_CMD=$(eval "autoproj manifest ${BOOTSTRAP_MANIFEST}")
    printf -- " -- Setting default ${AUTOPROJ_CMD}"
fi

printf -- " -- $(eval autoproj manifest)"

aup
printf -- " -- run amake "
amake


#!/bin/bash
#
# Copyright (c) Telemundo Digital Media
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished
# to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# This file contains bash functions and variables used by the repositories in:
#   http://github.com/telemundo

export VERSION=`echo -e '0.1.0'`
export GY=`echo -e '\033[1;30m'`
export RD=`echo -e '\033[1;31m'`
export GR=`echo -e '\033[1;32m'`
export YW=`echo -e '\033[1;33m'`
export BL=`echo -e '\033[1;34m'`
export MA=`echo -e '\033[1;35m'`
export CY=`echo -e '\033[1;36m'`
export WH=`echo -e '\033[1;37m'`
export NC=`echo -e '\033[0m'`

# Prints the script version
__cli_version() {
    local script="$1"
    if [ ! -z "$script" ]; then
        local version="$script $VERSION"
    else
        local version="$VERSION"
    fi
    echo "${GY}${version}${NC}"
}

__cli_spaces() {
    local spaces=""
    if [ -n "$1" ]; then
        local leading="${1-$spaces}  "
    else
        local leading="${spaces}  "
    fi
    echo "$leading"
}

# Prints a red formatted message
__cli_error() {
    local spaces="  "
    if [ -n "$1" ]; then
        local leading="${2-$spaces}"
        echo -e "${leading}${RD}${1}${NC}"
    fi
}

# Prints a yellow formatted message
__cli_warn() {
    local spaces="  "
    if [ -n "$1" ]; then
        local leading="${2-$spaces}"
        echo -e "${leading}${YW}${1}${NC}"
    fi
}

# Prints a green formatted message
__cli_info() {
    local spaces="  "
    if [ -n "$1" ]; then
        local leading="${2-$spaces}"
        echo -e "${leading}${GR}${1}${NC}"
    fi
}

# Checks if the OS is Darwin
__cli_osx() {
    local uname=`uname`
    if [ "$uname" == "Darwin" ]; then
        echo 1
    else
        echo 0
    fi
}

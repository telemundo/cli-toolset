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

# Global variables
SCRIPT_NAME=`basename $0`
SCRIPT_PATH=`dirname $0`
SCRIPT_LIBS="${SCRIPT_PATH}/common.sh"
SCRIPT_CONF="${SCRIPT_PATH}/.cliconfig"
LOCAL_PATH=`pwd -P`
LOCAL_CONF="${LOCAL_PATH}/.cliconfig"

# Load libraries & configuration scripts
test -f $SCRIPT_LIBS && . $SCRIPT_LIBS
test -f $SCRIPT_CONF && . $SCRIPT_CONF
test -f $LOCAL_CONF && . $LOCAL_CONF

# Returns the trunk url
getTrunkUrl() {
    echo "${REPO_URL}/trunk"
}

# Returns a branch url
getBranchUrl() {
    local branch="$1"
    echo "${REPO_URL}/branches/${branch}"
}

getBranchName() {
    local branch="$1"
    local output=`svn list $repo 2>/dev/null | cut -f -1 -d / | sed -e "s/^.*$/    ${CY}${branch}&${NC}/g"`
    echo "$output"
}

# Returns a development branch url
getDevelopmentBranch() {
    local branch="$1"
    local repo=`getBranchUrl "development/"`
    echo "${repo}${branch}"
}

# Returns a count of the user's development branches
getDevelopmentBranchCount() {
    local branch="$1"
    local repo=`getDevelopmentBranch $branch`
    echo `svn list $repo 2>/dev/null | wc -l`
}

# Returns a list of the user's development branches
getDevelopmentBranchNames() {
    local branch="$1"
    if [ ! -z "$branch" ]; then
        local id="${branch}\/"
    else
        local id=""
    fi
    local repo=`getDevelopmentBranch $branch`
    local output=`getBranchName "development\/${id}"`
    echo "$output"
}

# Returns a feature branch url
getFeatureBranch() {
    local branch="$1"
    local repo=`getBranchUrl "features/"`
    echo "${repo}${branch}"
}

# Returns a count of the feature branches
getFeatureBranchCount() {
    local repo=`getFeatureBranch`
    echo `svn list $repo 2>/dev/null | wc -l`
}

# Prints a list of the feature branches
getFeatureBranchNames() {
    local repo=`getFeatureBranch`
    local output=`getBranchName "features\/"`
    echo "$output"
}

# Returns a release branch url
getReleaseBranch() {
    local branch="$1"
    local repo=`getBranchUrl "releases/"`
    echo "${repo}${branch}"
}

# Returns a count of the release branches
getReleaseBranchCount() {
    local repo=`getReleaseBranch`
    echo `svn list $repo 2>/dev/null | wc -l`
}

# Prints a list of the release branches
getReleaseBranchNames() {
    local repo=`getReleaseBranch`
    local output=`getBranchName "releases\/"`
    echo "$output"
}

# Output a list of the current branches
BranchList() {
    local branch="$1"
    local developmentBranchCount=`getDevelopmentBranchCount $branch`
    local featureBranchCount=`getFeatureBranchCount`
    local releaseBranchCount=`getReleaseBranchCount`

    if [ $developmentBranchCount -gt "0" ]; then
        echo "  development: ${GR}${developmentBranchCount}${NC}"
        getDevelopmentBranchNames $branch
    else
        echo "  development: ${RD}${developmentBranchCount}${NC}"
    fi
    echo ""

    if [ -z "$branch" ]; then
        if [ $featureBranchCount -gt "0" ]; then
            echo "  features: ${GR}${featureBranchCount}${NC}"
            getFeatureBranchNames
            echo ""
        fi

        if [ $releaseBranchCount -gt "0" ]; then
            echo "  releases: ${GR}${releaseBranchCount}${NC}"
            getReleaseBranchNames
            echo ""
        fi
    fi
}

# Switches your working copy to a specific branch
BranchSwitch() {
    if [ -n "$1" ]; then
        local branch=`getBranchUrl "$1"`
        local branchinfo=`svn info $branch 2>/dev/null`
        local localinfo=`svn info 2>/dev/null`

        if [ ! -z "$branchinfo" ]; then
            if [ ! -z "$localinfo" ]; then
                svn switch --non-interactive $branch
                local switchinfo=`svn info 2>/dev/null`
                echo -e "\n$switchinfo"
            else
                local localdir=`pwd`
                __cli_error "is not a working copy!" "  ${WH}$localdir${NC}: "
            fi
        else
            __cli_error "does not exist!" "  ${WH}$branch${NC}: "
        fi
        echo ""
    else
        scriptUsage
    fi
}

# Creates a new branch from trunk
BranchCreate() {
    if [ -n "$1" ]; then
        local trunk=`getTrunkUrl`
        local branch=`getDevelopmentBranch "$1"`
        local branchinfo=`svn info $branch 2>/dev/null`
        
        if [ -z "$branchinfo" ]; then
            svn cp $trunk $branch -m "${SCRIPT_NAME}: creating development branch (${1})" 2>&1
        else
            __cli_error "already exists!" "  ${WH}$branch${NC}: "
        fi
        echo ""
    else
        scriptUsage
    fi
}

# Updates your branch with the latest changes from trunk #
BranchUpdate() {
    local localinfo=`svn info 2>/dev/null`

    if [ ! -z "$localinfo" ]; then
        local localupdates=`svn st 2>/dev/null`
        if [ -z "$localupdates" ]; then
            local trunk=`getTrunkUrl`
            svn merge --non-interactive -x -b -x -w -x --ignore-eol-style $trunk .
        else
            __cli_warn "You must commit all pending changes before you can update your branch." "  "
            echo -e "\n$localupdates"
        fi
    else
        __cli_error "is not a working copy!" "  ${WH}${SCRIPT_PATH}${NC}: "
    fi
    echo ""
}

# Prints the information of a branch
BranchInfo() {
    if [ -n "$1" ]; then
        local branch=`getBranchUrl "$1"`
        local branchinfo=`svn info $branch 2>/dev/null`
        
        if [ ! -z "$branchinfo" ]; then
            echo "$branchinfo"
        else
            __cli_error "does not exists!" "  ${WH}$branch${NC}: "
        fi
        echo ""
    else
        scriptUsage
    fi
}

# Merges your working copy into the trunk
BranchMerge() {
    local localinfo=`svn info . 2>/dev/null`

    if [ ! -z "$localinfo" ]; then
        echo "$localinfo"
    else
        __cli_error "is not a working copy!" "  ${WH}${SCRIPT_PATH}${NC}: "
    fi
    echo ""
}

# Purges all unversioned files from your working copy
BranchPurge() {
    svn revert -R . 2>/dev/null
    svn st . 2>/dev/null | grep -E "^\?" | cut -c 9- | xargs rm -rfv | xargs echo "Removed"
    
    echo ""
}

# Adds all unversioned files to your working copy
BranchAdd() {
    svn st . 2>/dev/null | grep -E "^\?" | cut -c 9- | xargs svn add
    echo ""
}

# Switches your working copy to the trunk
BranchExit() {
    local trunk=`getTrunkUrl`
    local localinfo=`svn info $trunk 2>/dev/null`

    if [ ! -z "$localinfo" ]; then
        svn switch --non-interactive $trunk
        local switchinfo=`svn info 2>/dev/null`
        echo -e "\n$switchinfo"
    else
        __cli_error "does not exist!" "  ${WH}${trunk}${NC}: "
    fi
    echo ""
}

# Run script checks
scriptChecks() {
    if [ -z "$REPO_URL" ]; then
        __cli_error "has not been set in any of the .cliconfig files." "  ${WC}REPO_URL${NC}: "
        echo ""
        exit 1
    fi
}

# Display usage instructions
scriptUsage() {
    echo "usage:"
    echo ""
    echo "  ${SCRIPT_NAME} ${WH}list${NC} [${GY}user${NC}]                     (outputs a list of development branches)"
    echo "  ${SCRIPT_NAME} ${WH}switch${NC} (${RD}branch${NC})                 (switches your working copy to the specified branch)"
    echo "  ${SCRIPT_NAME} ${WH}create${NC} (${RD}branch${NC})                 (creates a new branch based off trunk)"
    echo "  ${SCRIPT_NAME} ${WH}update${NC}                          (updates your branch with the latest changes from trunk)"
    echo "  ${SCRIPT_NAME} ${WH}info${NC} (${RD}branch${NC})                   (prints the branch information)"
    echo "  ${SCRIPT_NAME} ${WH}merge${NC}                           (merges your branch into the trunk)"
    echo "  ${SCRIPT_NAME} ${WH}purge${NC}                           (removes all unversioned files from your working copy)"
    echo "  ${SCRIPT_NAME} ${WH}add${NC}                             (adds all unversioned files to your working copy)"
    echo "  ${SCRIPT_NAME} ${WH}exit${NC}                            (switches your branch to the trunk)"
    echo ""
}

# Main routine
if [ -n "$1" ]; then
    __cli_version "$SCRIPT_NAME"
    echo ""
    scriptChecks
    scriptAction=$1
    shift
    case "$scriptAction" in
        "ls" | "list"   ) BranchList $*;;
        "sw" | "switch" ) BranchSwitch $*;;
        "cp" | "create" ) BranchCreate $*;;
        "up" | "update" ) BranchUpdate $*;;
        "info"          ) BranchInfo $*;;
        "merge"         ) BranchMerge $*;;
        "purge"         ) BranchPurge $*;;
        "add"           ) BranchAdd $*;;
        "exit"          ) BranchExit $*;;
        *               ) scriptUsage;;
    esac
else
    __cli_version "$SCRIPT_NAME"
    scriptUsage
fi

exit $?
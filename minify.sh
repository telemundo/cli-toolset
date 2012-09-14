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

# Script variables
CLOSURE_JAR="${SCRIPT_PATH}/lib/closure-20120710.jar"

# Minify file
MinifyFile() {
    local leading=`__cli_spaces "$2"`
    local source_path="${1}"
    if [ -f "$source_path" ]; then
        echo "${leading}${GY}${source_path}${NC}"
        local source_file_name="${source_path%.*}"
        local source_file_ext="${source_path##*.}"
        local source_file_min="${source_file_name}.min.${source_file_ext}"
        local source_file_type="$(tr [A-Z] [a-z] <<< "$source_file_ext")"
        if [ "$source_file_type" == "js" ]; then
            local minified=`java -jar "${CLOSURE_JAR}" --js "${source_path}" --js_output_file "${source_file_min}" --warning_level QUIET`
            #local minified=`java -jar "${CLOSURE_JAR}" --js "${source_path}" --create_source_map "${source_file_min}.map" --source_map_format=V3 --js_output_file "${source_file_min}" --warning_level QUIET`
        else
            __cli_error "cannot be minified!" "  ${leading}${WH}^${NC} "
        fi
    fi
}

# Minify directory
MinifyDirectory() {
    local leading=`__cli_spaces "$2"`
    local source_path="${1}"
    if [ -d "$source_path" ]; then
        echo "${leading}${CY}${source_path}${NC}"
        local source_dir_name="$(echo $source_path | sed 's/\/$//g')/"
        for source_file in `ls -1 "$source_dir_name" | grep -Ev "[-\.]min\.[js|css]"`; do
            local source_file_path="${source_dir_name}${source_file}"
            if [ -d "$source_file_path" ]; then
                MinifyDirectory "${source_file_path}" "${leading}"
            elif [ -f "$source_file_path" ]; then
                MinifyFile "$source_file_path" "${leading}"
            fi
        done
    fi
}

# Minifies all files
MinifyPath() {
    local source_path="${1}"
    if [ ! -z "$source_path" ]; then
        if [ -d "$source_path" ]; then
            MinifyDirectory "$source_path" ""
        elif [ -f "$source_path" ]; then
            MinifyFile "$source_path" ""
        else
            __cli_error "is not a valid path!" "  ${WH}${source_path}${NC}: "
        fi
    fi
    echo ""
}

# Run script checks
scriptChecks() {
    if [ ! -e "$CLOSURE_JAR" ]; then
        __cli_error "cannot be found." "  ${WH}${CLOSURE_JAR}${NC}: "
        echo ""
        exit 1
    fi
}

# Display usage instructions
scriptUsage() {
    echo "usage:"
    echo ""
    echo "  ${SCRIPT_NAME} [${GY}files${NC}] ...                     (runs the files passed to the script through the Closure compiler)"
    echo ""
}

# Main routine
if [ -n "$1" ]; then
    __cli_version "$SCRIPT_NAME"
    echo ""
    scriptChecks
    while [ $# -ne 0 ]; do
        MinifyPath "$1"
        shift
    done
else
    __cli_version "$SCRIPT_NAME"
    scriptUsage
fi

exit $?
#!/bin/bash

# Project files to search
PROJECTFILES=`find . -name '*.xib' -o -name '*.[mh]' -o -name '*.plist'`
# Dump File Location
outputFile="unusedImages.txt"
# Debug
debug=false
# Do Output to file
doFileOutput=false

# Usage Info
usage()
{
cat << _EOF_
    Prints unused images in an XCode project. Run this script from the root of the XCode project.
    This will search .xib, .h, .m, and .plist files for any reference to images in the project.

    USAGE: unused_images [OPTIONS]

    EXAMPLE: ~/scripts/unused_images.sh --debug -o=output.txt

    OPTIONS

    -o --output : Use this to output to file. Optionally specify filename
    --debug : Prints out debug info
    -h --help : Print out help info.

_EOF_
}

# Process arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --debug)
            debug=true
            ;;
        -o | --output)
            doFileOutput=true
            if [ ! -z "$VALUE" ]; then
                outputFile=$VALUE
            fi
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done


# #######################################################################################
# Start of script

# Print out message to command line or file
# @param $1 Print message if debug enabled.
# @param $2 If present, print even if debug disabled.
outputMessage()
{
if [ ! -z "$1" ]; then
    if $debug == true; then
        if $doFileOutput == true; then
            echo "$1" >> "$outputFile"
        else
            echo "$1"
        fi
    fi
fi

if [ ! -z "$2" ]; then
    if $doFileOutput == true; then
        echo "$2" >> "$outputFile"
    else
        echo "$2"
    fi
fi
}

if $debug == true; then
    echo "Begin Search for images..."
    if $doFileOutput == true; then
        echo "Will output to file: $outputFile"
    fi
fi

if $doFileOutput == true; then
    if [ ! -e "$outputFile" ]; then
        touch "$outputFile"
    fi

    if [ ! -w "$outputFile" ]; then
        echo "ERROR: cannot write to $outputFile"
        exit 1
    fi

    cat /dev/null > "$outputFile"
fi

find . -iname "*.jpg" -o -iname "*.png" -print0 | while read -r -d $'\0' i; do
    basename=$(basename "$i")

    outputMessage " "
    outputMessage "----------------------------------------------"
    outputMessage "Process File: $i"
    outputMessage "File Basename: $basename"

    result=$(grep -l "$basename" $PROJECTFILES)
    if [ -z "$result" ]; then
        subBasename=${basename//@2x/""}
        if [ "$subBasename" = "$basename" ]; then
            if $debug == true; then
                outputMessage "Did not find usage."
            else
                outputMessage "" "$i"
            fi
        else
            subResult=$(grep -l "$subBasename" $PROJECTFILES)
            if [ -z "$subResult" ]; then
                if $debug == true; then
                    outputMessage "Did not find usage. Did not find parent usage as well: $subBasename"
                else
                    outputMessage "" "$i"
                fi
            elif $debug == true; then
                outputMessage "Did not find usage, but did find parent usage ($subBasename) in file(s): $subResult"
            fi
        fi
    elif $debug == true; then
        outputMessage "Found in file(s): $result"
    fi
done

if $debug == true; then
    echo "DONE"
fi

if $doFileOutput == true; then
    echo "Search complete. Results can be found in the file: "$outputFile""
fi

# End of script
# #######################################################################################

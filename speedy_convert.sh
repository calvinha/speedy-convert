#!/bin/sh

#Constants 
readonly FILE="user_directory.txt"
readonly MIN_ARGUMENTS=2
readonly MAX_ARGUMENTS=4
readonly YEAR=$(date +"%y")



domain="http://www.cs.sjsu.edu/~mak/CS"
class_number=
date=


function usage(){
    echo "Usage: "
    exit 0
}


function read_file(){
    directory=$(head -n 1 $FILE)
}


function get_lectures(){
    file_type=".pptx"
    class_year_date="CS$class_number-$YEAR$date"
    
    url=$(printf '%s%s%s%s' "$domain$class_number" "/lectures/" "$class_year_date" "$file_type")
    
    cd $directory

    file_name="$class_year_date$file_type"
    
    wget $url
    unoconv -f pdf $file_name
    
    exit 0 
}


function get_assignments(){
    
}

#Check if the user_directory file exists 
if [ ! -f $FILE ] ; then
    echo "Specify the directory where the files will be stored: "
    read directory
    touch $FILE
    echo $directory > $FILE
else
    read_file
fi


#Check the total number of arguments 
if [ "$#" -lt $MIN_ARGUMENTS ] || [ "$#" -gt $MAX_ARGUMENTS ] ; then
    usage
else
    class_number=$1
    date=$2
    case "$#" in
        2 ) get_lectures;;
        4 ) get_assignments;;
        * ) usage;;
    esac
fi



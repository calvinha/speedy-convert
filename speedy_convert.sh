#!/bin/sh

#====================================================================
#  FILE: speedy_convert.sh
#
#  DESCRIPTION: Download lectures and assignments in pdf format from
#               Dr. Mak's SJSU course web page
#
# REQUIREMENTS: wget, unoconv 
#       AUTHOR: Calvin Ha
#
#===================================================================

#Constants 
readonly FILE="user-directories.txt"
readonly TOTAL_ARGUMENTS=3
readonly YEAR=$(date +"%y")
readonly PROGRAM_NAME=$0


domain="http://www.cs.sjsu.edu/~mak/CS"
class_number=
directory=
isSet=0


#== FUNCTION =====================================================
#        NAME: usage
#
# DESCRIPTION: Display the usage information     
#
#=================================================================

function usage(){
    echo "Usage:"
    echo "$PROGRAM_NAME <course> -l <date>"
    echo "$PROGRAM_NAME <course> -a <assignment-number>"

    echo ""
    echo "Options:"
    echo "-a        Download assignments"
    echo "-l        Download lectures"
    exit 1
}

#== FUNCTION =====================================================
#        NAME: read_file
#
# DESCRIPTION: Reads the user-directories.txt file to check if
#              the course already has an associated dircetory
#
#   PARAMETER 1: keycode to check for the directory
#
#=================================================================

function read_file(){

    while read line; do
        key_code="$1"
        #substring to store the key and check it if it matches
        key_check="${line:0:${#key_code}}"              
        directory_temp="${line:${#key_code}+1:${#line}}"
        if [ "$key_code" == "$key_check" ] ; then
            directory=$directory_temp #set the directory
            isSet=1
            cd $directory
            break 
        fi
    done < $FILE

}

#== FUNCTION =====================================================
#        NAME: check_file
#
# DESCRIPTION: Asks the user to specify file download destination
#              if the course was not listed in the file
#
#              Creates user-directories.txt file if it doesn't
#              exist
# PARAMETER 1: key code to check for the directory 
#
#=================================================================

function check_file(){
    #Check if the user_directory file exists
    if [ -f $FILE ] ; then
        read_file "$1" 
    fi
    
    if [ "$isSet" -eq  0 ] ; then 
        echo "Specify the directory where the files will be stored: "
        read directory
        touch $FILE
        echo "$1 $directory" >>  $FILE
        cd $directory
    fi
}

#== FUNCTION =====================================================
#        NAME: check_url
#
# DESCRIPTION: Checks if the url is valid
#
# PARAMETER 1: url to check
#
#=================================================================

function check_url() {
    url="$1"
    # check if the url is valid
    if ! curl --output /dev/null --silent --head --fail "$url"; then
        echo "File: $url is unavailable for download"
        echo "Check if the argument inputted is in the correct format"
        exit 0
    fi
}

#== FUNCTION =====================================================
#         NAME: get_lecture
#
#  DESCRIPTION: Uses wget to download the lecture from the webpage
#               uses unoconv to convert the pptx to a pdf file
#                            
#               
#              
#  PARAMETER 1: user specified date of the lecture
#
#=================================================================

function get_lecture(){
    date="$1"
    file_type=".pptx"
    class_year_date="CS$class_number-$YEAR$date"
    
    url=$(printf '%s%s%s%s' "$domain$class_number" "/lectures/" "$class_year_date" "$file_type")
    check_url $url

    month="${date:0:2}"
    day="${date:2:${#date}}"
    date_format="-$month-$day"
    new_file_name="$class_number$date_format$file_type"

    wget -O $new_file_name $url
    unoconv -f pdf $new_file_name

    powerpoint_directory="${class_number}_lecture_powerpoints"
    if [ ! -d $powerpoint_directory ]; then
        mkdir $powerpoint_directory
    fi
    mv $new_file_name $powerpoint_directory
    exit 0 
}

#== FUNCTION =====================================================
#         NAME: get_assignment
#
#  DESCRIPTION: Uses wget to download the assignment from the
#               webpage
#              
#  PARAMETER 1: user specified assignment number 
#
#=================================================================

function get_assignment(){

    assignment_num="$1"
    file_type=".pdf"
    assignment="Assignment$assignment_num"
    
    url=$(printf '%s%s%s%s%s' "$domain$class_number" "/assignments/" "$assignment_num/" "$assignment" "$file_type")
    check_url $url

    new_file_name="${class_number}-assignment$1$file_type"
    wget -O $new_file_name $url
    exit 0
}


#Check the total number of arguments 
if [ "$#" != $TOTAL_ARGUMENTS ] ; then
    usage
else
    class_number="$1"
    option="$2"
    key="$1 $2" # the key is represented by the class number and option 
    if [ "$option" == "-l" ] ;then
        check_file "$key"
        get_lecture "$3" #Passing in the date to the function 
    elif [ "$option" == "-a" ]; then
        check_file "$key"
        get_assignment "$3" #Passing in the assignment number to the function 
    fi
fi

#!/bin/sh

#====================================================================
#  FILE: speedy_convert.sh
#
#  DESCRIPTION: Download lectures and assignments in pdf format from
#              Dr. Mak's SJSU course web page
#
# REQUIREMENTS: wget, unoconv 
#       AUTHOR: Calvin Ha
#
#===================================================================

#Constants 
readonly FILE="user-directories.txt"
readonly MIN_ARGUMENTS=2
readonly MAX_ARGUMENTS=3
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
    echo "$PROGRAM_NAME <course> <date>"
    echo "$PROGRAM_NAME <course> -a <assignment-number>"

    echo ""
    echo "Options:"
    echo "-a        Download assignments"
    exit 1
}

#== FUNCTION =====================================================
#        NAME: read_file
#
# DESCRIPTION: reads the user-directories.txt file to check if
#              the course already has an associated dircetory
#
#=================================================================

function read_file(){

    while read line; do
        #substring to store the class number from the file
        class_check="${line:0:${#class_number}}"
        #substring to store the directory from the file
        directory_check="${line:${#class_number}+1:${#line}}"

        if [ "$class_number" == "$class_check" ] ; then
            directory=$directory_check #set the directory
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
#
#=================================================================

function check_file(){
    #Check if the user_directory file exists

    if [ -f $FILE ] ; then
        read_file
    fi
    
    if [ "$isSet" -eq  0 ] ; then 
        echo "Specify the directory where the files will be stored: "
        read directory
        touch $FILE
        echo "$class_number $directory" >>  $FILE
        cd $directory
    fi
}

#== FUNCTION =====================================================
#         NAME: get_lectures
#
#  DESCRIPTION: uses wget to download the lecture from the webpage
#               uses unoconv to convert the pptx to a pdf file
#                            
#               
#              
#  PARAMETER 1: user specified date of the lecture
#
#=================================================================

function get_lectures(){
    date="$1"
    file_type=".pptx"
    class_year_date="CS$class_number-$YEAR$date"
    
    url=$(printf '%s%s%s%s' "$domain$class_number" "/lectures/" "$class_year_date" "$file_type")

    file_name="$class_year_date$file_type"

    wget $url
    unoconv -f pdf $file_name
    
    exit 0 
}

#== FUNCTION =====================================================
#         NAME: get_lectures
#
#  DESCRIPTION: uses wget to download the assignment from the
#               webpage
#              
#  PARAMETER 1: user specified assignment number 
#
#=================================================================

function get_assignments(){

    assignment_num="$1"
    file_type=".pdf"
    assignment="Assignment$assignment_num"
    
    url=$(printf '%s%s%s%s%s' "$domain$class_number" "/assignments/" "$assignment_num/" "$assignment" "$file_type")
    wget $url
    exit 0

}


#Check the total number of arguments 
if [ "$#" -lt $MIN_ARGUMENTS ] || [ "$#" -gt $MAX_ARGUMENTS ] ; then
    usage
else
    class_number=$1
       
    case "$#" in
        2 ) check_file 
            get_lectures "$2";; #Passing in the date to the function 
        
        3) regex='^[1-9]' #limit the assignment number to single digits

            if [ "$2" != "-a" ] || ! [[ "$3" =~ $regex ]]; then
                usage
            else
                check_file 
                get_assignments "$3" #Passing in the assignment number to the function 
            fi;;
        
        * ) usage;;
    esac
fi



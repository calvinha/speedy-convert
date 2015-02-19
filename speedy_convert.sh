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
    exit 1
}


function read_file(){
    directory=$(head -n 1 $FILE)
}


function get_lectures(){
    file_type=".pptx"
    class_year_date="CS$class_number-$YEAR$date"
    
    url=$(printf '%s%s%s%s' "$domain$class_number" "/lectures/" "$class_year_date" "$file_type")

    file_name="$class_year_date$file_type"
    
    wget $url
    unoconv -f pdf $file_name
    
    exit 0 
}


function get_assignments(){

    assignment_num="$1"
    file_type=".pdf"
    assignment="Assignment$assignment_num"
    
    url=$(printf '%s%s%s%s%s' "$domain$class_number" "/assignments/" "$assignment_num/" "$assignment" "$file_type")
    wget $url
    exit 0

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
    cd $directory
    
    case "$#" in
        2 ) get_lectures;;
        
        4 ) regex='^[1-9]' #limit the assignment number to single digits

            if [ "$3" != "-a" ] || ! [[ "$4" =~ $regex ]]; then
                usage
            else
                get_assignments "$4" #Passing in the assignment number to the function 
            fi;;
        
        * ) usage;;
    esac
fi



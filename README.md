# Speedy Convert

Quickly download lectures/assignments from Dr. Mak's SJSU course webpage 

## Dependencies  
This bash script is dependent on
* [wget](https://www.gnu.org/software/wget/)
* [unoconv](https://github.com/dagwieers/unoconv)

## Usage
`./speedy_convert.sh <course> <date>`

* This will download the lecture on the specified date from the course

## Example
`./speedy_convert.sh 149 0205`

* This downloads the powerpoint lecture from the course CS 174 on February 5.
* The script then converts the powerpoint to pdf storing both files to user specified directory
* __Note__ the lead zero to indicate the month February 

## Optional Argument
* To download assignments use the -a option after the course
`./speedy_convert.sh 149 -a 2`
* This downloads assignment 2 from CS 149 

## Motivation
Opening Microsoft Powerpoint presentations has always been slow on my Mac. Thus, I convert them to a pdf file instead. Having to convert a powerpoint to pdf every time was time consuming, so I made this script to remove the unnecessary steps.

This script works because Dr. Mak uses a consistent format for naming his files.

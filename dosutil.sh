#!/bin/bash
#Purpose: This script performs basic file management functins on Linux/Unix for DOS/Windows users that are not familiar with Linux/Unix
#Last Revision Date:  3/26/25
#Variables:
#ARG1 = the first argument used in the command
#ARG2 = the second argument used in the command
#ARG3 = the third argument used in the command
#HELP_MESSAGE = the help message outputted when the help commaand is used or if there is any invalid parameter

HELP_MESSAGE='
Supported Commands:\n
author \t  \t  \t  \t outputs the author of this script\n
type [filename] \t  \t  \t outputs the contents of the file [filename]\n
\n
copy [orig_file] [dest_file] \t  \t copies the file [orig_file] to the file path [dest_file], but does not overwrite existing files\n
copy! [orig_file] [dest_file] \t  \t copies the file [orig_file] to the file path [dest_file], automatically overwriting existing files\n
\n
ren [orig_file] [new_name] \t  \t renames the file [orig_file] to [new_name], but does not overwrite existing files\n
ren! [orig_file] [new_name] \t  \t renames the file [orig_file] to [new_name], automatically overwriting existing files\n
\n
move [orig_file] [dest_file] \t  \t moves the file [orig_file] from its original location to the file path [dest_file], but does not overwrite existing\n
 \t  \t  \t  \t  \t files\n
move! [orig_file] [dest_file] \t  \t moves the file [orig_file] from its original location to the file path [dest_file], automatically overwriting existing\n
 \t  \t  \t  \t  \t files\n
\n
del [filename] \t  \t  \t deletes the file [filename]\n
verify [filename]  \t  \t  \t verifies that the file [filename] exists, and determines whether it is a directory or not\n
\n
perms [filename] [permission_bits] \t changes the permission bits of the file [filename] based on the inputted [permission_bits]\n
groupchange [filename] [group_name] \t changes the file [filename] so that it is now owned by the group [group_name], only works when used in "sudo" mode\n
\n
first [filename] [number_of_lines] \t reads the first [number_of_lines] lines in the file [filename]\n
last [filename] [number_of_lines] \t reads the last [number_of_lines] lines in the file [filename]\n
\n
help \t  \t  \t  \t  \t outputs a list of supported commands, their action, and required parameters\n
'

#read arguments ..
ARG1=$(echo "$1" | tr '[A-Z]' '[a-z]')  # first argument used in the command, converted to all lowercase
ARG2=$2  # second argument used in the command
ARG3=$3 # third argument used in the command


# -----FUNCTIONS-----
#Function to verify if a file exists
verify_file_exists() {
    test -s "$1" && return 0 || return 1
}

# Function to verify if a given file is a directory
directory_test() {
    test -d "$1" && return 0 || return 1
}

#Function that prints author info
print_author() {
    echo "toastercrusade on Github"
    if [ $? -eq 0 ]; then
            printf "\n"
            echo "Operation Successful"
            echo 'UNIX command ran: echo "Schiciano, Dominic"'
            printf "\n"
        else
            echo 'Operation failed: use the "help" command for more information'
    fi
}

#Function that prints file contents
print_type() {
    if verify_file_exists "$1"; then
        cat $1
        if [ $? -eq 0 ]; then
            printf "\n"
            echo "Operation Successful"
            printf 'UNIX command ran: cat %s' "$1"
            printf "\n"
        else
            echo 'Operation failed: use the "help" command for more information'
        fi
    else
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that copies a file into another file, but does not overwrite existing files
copy_file() {
    if verify_file_exists "$1"; then
        if [[ -n "$2" ]]; then
            if verify_file_exists "$2"; then
            echo "Operation failed"
            printf "File already exists: %s\n" "$2"
            echo "Use the [copy!] command to overwrite an existing file"
        else
            if directory_test "$1"; then
                cp -r $1 $2 > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "Operation Successful"
                    printf 'UNIX command ran: cp -r %s %s\n' "$1" "$2"
                    printf "\n"
                else
                    echo 'Operation failed: use the "help" command for more information'
                fi
            else
                cp $1 $2 > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "Operation Successful"
                    printf 'UNIX command ran: cp %s %s\n' "$1" "$2"
                    printf "\n"
                else
                    echo 'Operation failed: use the "help" command for more information'
                fi
            fi
        fi
        else
            echo "Operation failed"
            echo "Missing second parameter!"
        fi
    else 
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that copies a file into another file, overwriting existing files
copy_file_overwrite() {
    if verify_file_exists "$1"; then
        if [[ -n "$2" ]]; then
            if directory_test "$1"; then
                if verify_file_exists "$2"; then
                    del_file "$2"
                fi
                cp -r $1 $2 > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "Operation Successful"
                    printf 'UNIX command ran: cp -r %s %s\n' "$1" "$2"
                    printf "\n"
                else
                    echo 'Operation failed: use the "help" command for more information'
                fi
            else
                cp $1 $2 > /dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "Operation Successful"
                    printf 'UNIX command ran: cp %s %s\n' "$1" "$2"
                    printf "\n"
                else
                    echo 'Operation failed: use the "help" command for more information'
                fi
            fi
        else
            echo "Operation failed"
            echo "Missing second parameter!"
        fi
    else 
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that accomplishes both the rename and move functionality, but does not overwrite existing files
ren_or_move() {
    if verify_file_exists "$1"; then
        if [[ -n "$2" ]]; then
            echo "Operation failed"
            printf "Cannot overwrite file: %s\n" "$1"
            if [[ $3 == *"ren"* ]]; then
                echo "Use the [ren!] command to overwrite an existing file"
    
            elif [[ $3 == *"move"* ]]; then
                echo "Use the [move!] command to overwrite an existing file"
            fi
        else
            echo "Operation failed"
            echo "Missing second parameter!"
        fi
    else 
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that accomplishes both the rename and move functionality, overwriting existing files
ren_or_move_overwrite() {
    if verify_file_exists "$1"; then
        if [[ -n "$2" ]]; then
            mv $1 $2 > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                printf "\n"
                echo "Operation Successful"
                printf 'UNIX command ran: mv %s %s\n' "$1" "$2"
                printf "\n"
            else
                echo echo 'Operation failed: use the "help" command for more information'
            fi
        else
            echo "Operation failed"
            echo "Missing second parameter!"
        fi
    else 
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that deletes a file without asking for confirmation
del_file() {
    if verify_file_exists "$1"; then
        if directory_test "$1"; then
            rm -rf $1 > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                printf "\n"
                echo "Operation Successful"
                printf 'UNIX command ran: rm -rf %s %s\n' "$1" "$2"
                printf "\n"
            else
                   echo 'Operation failed: use the "help" command for more information'
            fi
        else
            rm -f $1 > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                printf "\n"
                echo "Operation Successful"
                printf 'UNIX command ran: rm -f %s %s\n' "$1" "$2"
                printf "\n"
            else
                echo 'Operation failed: use the "help" command for more information'
            fi
        fi
    else
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}
#Function that changes the permissions on a file
change_permissions() {
    if verify_file_exists "$1"; then
        chmod "$2" "$1"
        if [ $? -eq 0 ]; then
            printf "\n"
            echo "Operation Successful"
            printf 'UNIX command ran: chmod %s %s\n' "$2" "$1"
            printf "\n"
        else
            echo 'Operation failed: use the "help" command for more information'
        fi
    else
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that changes the group that owns a file
change_group() {
    if verify_file_exists "$1"; then
        chgrp "$2" "$1" > /dev/null 2>&1
        if [ $? -eq 0 ]; then            
            printf "\n"
            echo "Operation Successful"
            printf 'UNIX command ran: chgrp %s %s\n' "$2" "$1"
            printf "\n"
        else
            echo 'Operation failed: use the "help" command for more information'
        fi
    else
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that prints the first x lines of a file
first_lines() {
    if verify_file_exists "$1"; then
        if directory_test "$1"; then
            echo "Operation failed"
            printf "File %s is a directory\n" "$1"
        else
            head -n "$2" "$1"
            if [ $? -eq 0 ]; then
                echo "Operation Successful"
                printf 'UNIX command ran: head -n %s %s\n' "$2" "$1"
                printf "\n"
            else
                echo 'Operation failed: use the "help" command for more information'
            fi
        fi
    else
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}

#Function that prints the last x lines of a file
last_lines() {
    if verify_file_exists "$1"; then
        if directory_test "$1"; then
            echo "Operation failed"
            printf "File %s is a directory\n" "$1"
        else
            tail -n "$2" "$1"
            if [ $? -eq 0 ]; then
                echo "Operation Successful"
                printf 'UNIX command ran: tail -n %s %s\n' "$2" "$1"
                printf "\n"
            else
                echo 'Operation failed: use the "help" command for more information'
            fi
        fi
    else
        echo "Operation failed"
        printf "File not found: %s\n" "$1"
    fi
}
# -----CASES-----
#Chooses a specific set of operations 
case $ARG1 in
    #runs interactive mode if there is no ARG1
    "")
        FILE_LIST=($(ls | sort)) #stores a list of files in the current directory
        POSSIBLE_COMMANDS=("author" "type" "copy" "copy!" "ren" "ren!" "move" "move!" "del" "verify" "perms" "groupchange" "first" "last" "help") # List of possible commands the user can run
        SORT_OPTIONS=("name (default)" "size" "age")

        printf "\n"
        echo "-----Select a Sorting Option for File List-----"
        select option in "${SORT_OPTIONS[@]}"; do
            if [[ $option == "name (default)" ]]; then
                FILE_LIST=($(ls | sort))
            elif [[ $option == "size" ]]; then
                FILE_LIST=($(ls -S))
            elif [[ $option == "age" ]]; then
                FILE_LIST=($(ls -t))
            else
                FILE_LIST=($(ls | sort))
            fi
            break
        done
        printf "\n"
        echo "-----Select a File-----"
        select file in "${FILE_LIST[@]}"; do # Prompts the user to select a file from the list
            if [[ -n "$file" ]]; then  # Checks if the user selected a valid file
                echo "You selected: $file"
                printf "\n"
                echo "-----Select a command-----"
                select command in "${POSSIBLE_COMMANDS[@]}"; do # Prompts the user to select a command from the list
                    if [[ -n "$command" ]]; then # Checks if the user selected a valid command
                        echo "You selected: $command"
                        printf "\n"
                        case $command in # calls function based on command selected
                            "author")
                                print_author
                                break
                                ;;
                            #runs the print_type() function
                            "type")
                                print_type "$file"
                                break
                                ;;
                            #runs the copy_file() function
                            "copy")
                                read -p "Enter filepath location for copied file: " filepath
                                copy_file "$file" "$filepath"
                                break
                                ;;                                                                                                             
                            #runs the ren_or_move() function
                            "ren")
                                read -p "Enter new filename: " filename
                                ren_or_move "$file" "$filename" "$command"
                                break
                                ;;
                            #runs the ren_or_move() function
                            "move")
                                read -p "Enter new filepath location: " filepath
                                ren_or_move "$file" "$filepath" "$command"
                                break
                                ;;
                            #runs the copy_file_overwrite() function
                            "copy!")
                                read -p "Enter filepath location for copied file: " filepath
                                copy_file_overwrite "$file" "$filepath"
                                break
                                ;;
                            #runs the ren_or_move_overwrite() function
                            "ren!")
                                read -p "Enter new filename: " filename
                                ren_or_move_overwrite "$file" "$filename" "$command"
                                break
                                ;;
                            #runs the ren_or_move_overwrite() function
                            "move!")
                                read -p "Enter new filepath location: " filepath
                                ren_or_move_overwrite "$file" "$filepath" "$command"
                                break
                                ;;
                            #runs the del_file() function
                            "del")
                                del_file "$file"
                                break
                                ;;
                            #runs the verify_file_exists() function, as well as the directory_test function
                            "verify")
                                if verify_file_exists "$file"; then
                                    printf "Operation Successful, found file '%s'\n" "$file"
                                    printf 'test -s %s && return 0 || return 1\n' "$file"
                                    printf "\n"
                                    if directory_test "$file"; then
                                        printf "Operation Successful, file '%s' is a directory\n" "$file"
                                        printf 'test -d %s && return 0 || return 1\n' "$file"
                                        printf "\n"
                                    else
                                        printf "Operation Successful, file '%s' is not a directory\n" "$file"
                                        printf 'test -d %s && return 0 || return 1\n' "$file"
                                        printf "\n"
                                    fi
                                else
                                    printf "Operation failed, could not find file '%s'\n" "$file"
                                    printf 'test -s %s && return 0 || return 1\n' "$file"
                                    printf "\n"
                                fi
                                break
                                ;;
                            #runs the change_permissions function
                            "perms")
                                read -p "Enter permission bits: " permBits
                                change_permissions "$file" "$permBits"
                                break
                                ;;
                            #runs the change_group function
                            "groupchange")
                                read -p "Enter new group owner: " groupOwner
                                change_group "$file" "$groupOwner"
                                break
                                ;;
                            #runs the first_lines function
                            "first")
                                read -p "Enter number of lines to be read: " lines
                                first_lines "$file" "$lines"
                                break
                                ;;
                            #runs the last_lines function
                            "last")
                                read -p "Enter number of lines to be read: " lines
                                last_lines "$file" "$lines"
                                break
                                ;;
                            #outputs the help message
                            "help")
                                echo -e $HELP_MESSAGE
                                echo "-----Select a command-----"
                                for command in "${!POSSIBLE_COMMANDS[@]}"; do
                                    echo "$((command+1))) ${POSSIBLE_COMMANDS[$command]}"
                                done
                                ;;
                        esac
                    else
                        echo "Invalid selection. Please try again."
                    fi
                done
                break
            else
                echo "Invalid selection. Please try again."
            fi
        done
        ;;
	#runs the print_author() function
	"author")
		print_author
		;;
	#runs the print_type() function
	"type")
		print_type "$ARG2"
		;;
    #runs the copy_file() function
	"copy")
        copy_file "$ARG2" "$ARG3"
		;;                                                                                                             
    #runs the ren_or_move() function
    "ren")
        ren_or_move "$ARG2" "$ARG3" "$ARG1"
		;;
    #runs the ren_or_move() function
    "move")
		ren_or_move "$ARG2" "$ARG3" "$ARG1"
		;;
    #runs the copy_file_overwrite() function
	"copy!")
        copy_file_overwrite "$ARG2" "$ARG3"
		;;
    #runs the ren_or_move_overwrite() function
    "ren!")
        ren_or_move_overwrite "$ARG2" "$ARG3"
		;;
    #runs the ren_or_move_overwrite() function
    "move!")
		ren_or_move_overwrite "$ARG2" "$ARG3"
		;;
    #runs the del_file() function
    "del")
		del_file "$ARG2"
		;;
    #runs the verify_file_exists() function, as well as the directory_test function
	"verify")
		if verify_file_exists "$ARG2"; then
            printf "Operation Successful, found file '%s'\n" "$ARG2"
            printf 'test -s %s && return 0 || return 1\n' "$ARG2"
            printf "\n"
            if directory_test "$ARG2"; then
                printf "Operation Successful, file '%s' is a directory\n" "$ARG2"
                printf 'test -d %s && return 0 || return 1\n' "$ARG2"
                printf "\n"
            else
                printf "Operation Successful, file '%s' is not a directory\n" "$ARG2"
                printf 'test -d %s && return 0 || return 1\n' "$ARG2"
                printf "\n"
            fi
        else
            printf "Operation failed, could not find file '%s'\n" "$ARG2"
            printf 'test -s %s && return 0 || return 1\n' "$ARG2"
            printf "\n"
        fi
		;;
    #runs the change_permissions function
    "perms")
		change_permissions "$ARG2" "$ARG3"
        ;;
    "groupchange")
    #runs the change_group function
        change_group "$ARG2" "$ARG3"
        ;;
    #runs the first_lines function
    "first")
        first_lines "$ARG2" "$ARG3"
        ;;
    #runs the last_lines function
    "last")
        last_lines "$ARG2" "$ARG3"
        ;;
    #outputs the help message
    "help")
		echo -e $HELP_MESSAGE
        printf "\n"
        echo "Enter no command to enter interactive mode"
        ;;
    #triggers if there is an invalid parameter, outputs the command and then the help message
    *)
        printf "Invalid parameter: %s\n" "$*" 
        echo -e $HELP_MESSAGE
        prtinf "\n"
        echo "Enter no command to enter interactive mode"
        ;;
esac

#successful escape code
exit 0
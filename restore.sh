#!/bin/bash
#Purpose: This script restores a specified file backup
#It is assumed the script is ran using "sudo"
#Last Revision Date:  4/30/25

#-----VARIABLES-----
#ARG1 = the first argument used in the command (should be backup name)
#FILENAME = the name of the backup file to restore
#RESTORE_LOCATION = the location to restore the backup to
#CONFIRMATION_OPTIONS = an array containing the options the user can choose from whenthe script asks them to verify the operation

#read arguments ..
ARG1=$1  # first argument used in the command (should be backup name)

# Saving the first parameter as the name of the backup file to restore
FILENAME="$ARG1" 

# Saving an array containing the options the user can choose from when...
# ...the script asks them to verify the operation
CONFIRMATION_OPTIONS=("yes" "no")

# Verifying the specified file exists
if ! [ -f "$FILENAME" ]; then
    echo "ERROR"
    printf "File does not exist: %s\n" "$FILENAME"
    exit 1
fi

# Grabbing the location to restore the backup to fron the backup filename
RESTORE_LOCATION=$(echo "$FILENAME" | cut -d '.' -f 3) > /dev/null 2>&1
if ! [ $? -eq 0 ]; then
    echo "ERROR"
    echo 'Filename "%s" not properly formatted\n' "$FILENAME"
    exit 2
fi

printf "\n"
printf "You are about to restore the backup to: /%s\n" "$RESTORE_LOCATION"
echo "This will overwrite existing files in that directory."
echo "Are you sure you want to proceed?"
select option in "${CONFIRMATION_OPTIONS[@]}"; do
    if [[ $option == "yes" ]]; then
        # Decompressing based on suffix...
        # Before removing said suffix from FILENAME
        if [[ "$FILENAME" == *".gz" ]]; then
            # attempting to do "[unzip gz file] [keep] [filename] [destination]
            gunzip -k "$FILENAME"
            FILENAME="${FILENAME%.gz}"
        elif [[ "$FILENAME" == *".bz2" ]]; then
        # attempting to do "[unzip bz2 file] [keep] [filename] [destination]
            bzip2 -dk "$FILENAME"
            FILENAME="${FILENAME%.bz2}"
        else
            echo "ERROR"
            echo "Unsupported compression type"
            exit 3
        fi
        
        
        # Decompresses the tar file onto the correct location, replacing the existing location
        tar --force-local -xf "$FILENAME" -C "/" && rm -f "$FILENAME" && rm -rf "/$RESTORE_LOCATION/$RESTORE_LOCATION"
        if [ $? -eq 0 ]; then
            printf "\n"
            echo "SUCCESS!"
        fi

        break
    else
        echo "Operation Aborted"
        break
    fi
done

#successful escape code
exit 0
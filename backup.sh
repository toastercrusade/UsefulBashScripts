#!/bin/bash

#-----VARIABLES-----
#ARG1 = the first argument used in the command (should be backup name)
#BACKUP_NAME = the name of the backup to do
#CONFIG_FILE = the location of the config file
#COMPRESSION = the type of compression program for the backup
#E_MAIL = the email to which the daily log should be sent
#BACKUP_TARGET = the filesystem where the backup files are stored
#TARGET_TYPE = the type of filesystem used in the backup target
#TARGET_SERVER = the DNS name of the target server if it is not local
#TARGER_FS = the filesystem/share/export on the target server that will be mounted to BACKUP_TARGET
#USER = username for SMB target
#PASSWORD = password for the USER
#NAME = the name of the backup
#DIRECTORY = the directory entry for this backup
#RECURSIVE = whether or not the backup should be recursive (backup sub-directories)
#NUM_DAILY = the number of daily copies to keep
#NUM_WEEKLY = the number of weekly copies to keep
#NUM_MONTHLY = the number of monthly copies to keep
#HOSTNAME = the hostname of the device running the script
#DATE = the date at which the backup was created
#HOUR = Saving the hour at which the backup was created to a variable
#MINUTE = Saving the minute at which the backup was created to a variable
#BACKUP_FILE_NAME = the name of the backup file, properly formatted
#LOG_FILE_NAME = the name of the log file for the backup, properly formatted
#LOGS_FILEPATH = the filepath for log files

# Saving the hostname of the device running the script to a variable
HOSTNAME=$(hostname)
# Saving the date at which the backup was created to a variable
DATE=$(date '+%Y-%m-%d')
# Saving the hour at which the backup was created to a variable
HOUR=$(date '+%H')
# Saving the minue at which the backup was created to a variable
MINUTE=$(date '+%M')

#read arguments ..
ARG1=$1  # first argument used in the command (should be backup name)

# Verifies a user included a backup name as a parameter
if [ -z "$1" ]; then
    echo "ERROR"
    echo "Usage: $0 [backup_name]"
    exit 1
fi

#-----Gathering variables-----
# Sets BACKUP_NAME to be the first argument
BACKUP_NAME="$1"

# Saves the location of the conf file
CONFIG_FILE="/etc/backup.conf"

#Saves the filepath for log files
LOGS_FILEPATH="/var/log/backup"

# Gathers the lines from the .conf file that include the names of the variables, ...
# ...before removing the part that says "[variable name]=" and trimming off any carriage returns
COMPRESSION=$(grep -E '^COMPRESSION=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
E_MAIL=$(grep -E '^E_MAIL=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
BACKUP_TARGET=$(grep -E '^BACKUP_TARGET=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
TARGET_TYPE=$(grep -E '^TARGET_TYPE=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
TARGET_SERVER=$(grep -E '^TARGET_SERVER=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
TARGET_FS=$(grep -E '^TARGET_FS=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
USER=$(grep -E '^USER=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')
PASSWORD=$(grep -E '^PASSWORD=' "$CONFIG_FILE" | cut -d '=' -f2- | tr -d '\r')

# Saves the line that starts with BACKUP_NAME
BACKUP_LINE=$(grep "^$BACKUP_NAME:" "$CONFIG_FILE")

# Checks to make sure there is a backup name in the .conf file
if [ -z "$BACKUP_LINE" ]; then
    echo "ERROR"
    echo "No backup configuration found for '$BACKUP_NAME'"
    exit 2
fi

# Reads the backup line and then saves each delimited varibable, delimited with ":", to it's own variable
IFS=':' read -r NAME DIRECTORY RECURSIVE NUM_DAILY NUM_WEEKLY NUM_MONTHLY <<< "$BACKUP_LINE"

#-----Printing the variables-----
# Echo variables
printf "\n"
echo "-----VARIABLES-----"
echo "COMPRESSION=$COMPRESSION"
echo "E_MAIL=$E_MAIL"
echo "BACKUP_TARGET=$BACKUP_TARGET"
echo "TARGET_TYPE=$TARGET_TYPE"
echo "TARGET_SERVER=$TARGET_SERVER"
echo "TARGET_FS=$TARGET_FS"
echo "USER=$USER"
echo "PASSWORD=$PASSWORD"

# Echo backup entry variables
printf "\n"
echo "-----BACKUP ENTRY VARIABLES-----"
echo "NAME=$NAME"
echo "DIRECTORY=$DIRECTORY"
echo "RECURSIVE=$RECURSIVE"
echo "NUM_DAILY=$NUM_DAILY"
echo "NUM_WEEKLY=$NUM_WEEKLY"
echo "NUM_MONTHLY=$NUM_MONTHLY"

#-----Creating log files-----
# Creates the logs folder
mkdir -p "$LOGS_FILEPATH"
chmod 777 "$LOGS_FILEPATH"

# Creates a variable containing the name of the log file for the backup, properly formatted
LOG_FILE_NAME="$NAME.$DATE.$HOUR:$MINUTE"

# Creates the log file
touch "$LOGS_FILEPATH/$LOG_FILE_NAME"
chmod 777 "$LOGS_FILEPATH/$LOG_FILE_NAME"
# Inputs information into the log file
printf "Date of backup: %s\n" "$DATE" >> "$LOGS_FILEPATH/$LOG_FILE_NAME"
printf "Time of backup: %s:%s\n" "$HOUR" "$MINUTE" >> "$LOGS_FILEPATH/$LOG_FILE_NAME"
printf "\n" >> "$LOGS_FILEPATH/$LOG_FILE_NAME"
echo "-----List of Files Backed Up-----" >> "$LOGS_FILEPATH/$LOG_FILE_NAME"

#-----Creating the backup-----
# Creates the backup target directory if it does not already exist
mkdir -p "$BACKUP_TARGET/adhoc/"
chmod 777 "$BACKUP_TARGET"
chmod 777 "$BACKUP_TARGET/adhoc/"

# Creates a variable containing the name of the backup file, properly formatted
BACKUP_FILE_NAME="$HOSTNAME.$NAME.$DATE.$HOUR:$MINUTE.tar"

# Creating the tar file containing the backup and then sends stdout of the tar command into the log file
tar -cvf "$BACKUP_TARGET/adhoc/$BACKUP_FILE_NAME" "$DIRECTORY" >> "$LOGS_FILEPATH/$LOG_FILE_NAME"

#-----Compressing the backup-----
#TODO: Compression

#Print statements to verify a backup was completed
printf "\n"
printf 'Operation ran successfully: backed up %s to %s/adhoc/%s\n' "$DIRECTORY" "$BACKUP_TARGET" "$BACKUP_FILE_NAME"





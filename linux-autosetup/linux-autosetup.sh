#!/bin/bash

# Require run as root
#if [ $(id -u) -ne 0 ]; then
#	echo "Please run script as root! Exiting..."
#	exit 1
#fi

#########################
# VARIABLE DECLARATIONS #
#########################

# String used to substitute hyphens in creating custom functions
declare hyphenConversion='1_1'
# String to detect in appstrings as indication of separate dirs
declare stringSeparator=';;'
# String used to substitute for app names
declare name='_name_'

# Script working directory
# If a command call uses cd, this will allow remaining in proper dir
declare SCRIPT_WORKING_DIR="$(pwd)"
# Where application backups go
declare APP_BACKUP_DIR="./app-backups"
# Default backup type of apps
# Backup types: "ARCHIVE", "HARDLINK"
declare APP_BACKUP_TYPE="ARCHIVE"
# Where recovery files go
declare RECOVERY_BACKUP_DIR="./recovery"
# Where to dump files
declare DUMP_DIR="./dumps/dump"
# Where classes are stored
declare CLASSES_DIR="./classes"
# Default configiguration file
declare CONFIG_FILE="./autosetup_default.conf"

# Default install command used if one is not specified for app
# $nameSubstitution is substituted for app name
declare DEFAULT_APP_INSTALL_COMMAND="echo User must set DEFAULT_APP_INSTALL_COMMAND in configuration file. $name will not be installed until this is done."

# Stores applications as keys
# Stores "app strings" as data
declare -ag apps

# Stores app groups as keys
# Stores apps separated by spaces as data
declare -ag appGroups

####################
# GLOBAL FUNCTIONS #
####################

# Make sure directory is valid; otherwise exit script
requireExistingDir() {
	if [ ! -d "$1" ]; then
		echo
		echo "Error: $1 was not found."
		echo "Do you want the following directory to be created for you?" 
		echo "$1"
		echo "Type 'yes' to confirm, otherwise, script will exit."
		
		echo -n ": "
		read userIn
		if [[ "$userIn" = 'y' || "$userIn" = 'yes' ]]; then
			echo "Creating directory to: $1"
			mkdir -p "$1"
		else
			echo "Exiting..."
			exit
		fi
	fi
}

# Return extracted string from backup sourcePaths string.
# Takes $1 = string, $2 = field
extractSourcePath() {
	declare substring="$1"
	declare -i int=$2
	for (( j=1; j<$int; j++ ))
	do
		oldString=$substring
		substring=${substring##*"$stringSeparator"}
		if [[ $oldString = $substring ]]; then
			substring=''
			return
		fi
	done
	
	substring=${substring%"$stringSeparator"*}
	echo $substring
}

# Move $2 = directory/file to $DUMP_DIR/$1
# $1 = type of files to dump
dump() {
	requireExistingDir "$DUMP_DIR"
	# Idea to implement here: if $1 is "initialize,"
	# then create a new dump directory
	# Otherwise, $1 should be the sourcePath to dump.
	if [[ -d "$2" || -f "$2" ]]; then
		declare -i i=1
		while [ -d "$DUMP_DIR/$1$i" ]
		do
			echo "$DUMP_DIR/$1$i already exists."
			i+=1
			echo "Trying $DUMP_DIR/$1$i..."
		done
		mkdir "$DUMP_DIR/$1$i"
		mv "$2" "$DUMP_DIR/$1$i"
	else
		echo "Error: $2 was not found"
	fi
}

# Functions used to construct new objects
# Param $1 = name, additional params come after
app() {
	noHyphens=$(convertHyphens "$1")
	. <(sed "s/fields/$noHyphens/g" <(sed "s/app/$1/g" "$CLASSES_DIR"/app.class))
	$1.constructor "$2" "$3" "$4"
}
appGroup() {
	noHyphens=$(convertHyphens "$1")
	. <(sed "s/fields/$noHyphens/g" <(sed "s/appGroup/$1/g" "$CLASSES_DIR"/appGroup.class))
	$1.constructor
}
recovery() {
	noHyphens=$(convertHyphens "$1")
	. <(sed "s/fields/$noHyphens/g" <(sed "s/recovery/$1/g" "$CLASSES_DIR"/recovery.class))
	$1.constructor "$2" "$3"
}

# String converter methods to allow functionality with Bash
# Convert '-' and $hyphenConversion from and to each other
convertHyphens() {
	echo ${1//-/"$hyphenConversion"}
}

# Return all apps separated by spaces
apps() {
	for app in "${apps[@]}"; do
		echo -n " $app"
	done
	echo
}

# Return all appGroups separated by spaces
appGroups() {
	for appGroup in "${appGroups[@]}"; do
		echo -n " $appGroup"
	done
	echo
}

###############
# SCRIPT BODY #
###############

# Import config autosetup.conf
. autosetup.conf

# Create APP appGroup
appGroup ALL
# Import apps.conf
# Skip lines that do not need to be parsed
# Detects and assigns apps to groups
while IFS= read -r line; do
	# If line is empty or a comment
	if [[ "$line" = '' || ${line:0:1} = '#' ]]; then
		continue
	fi
	
	if [ "$line" = 'APPLICATIONS' ]; then
		section='APPLICATIONS'
		continue
	elif [ "$line" = 'APPLICATION_GROUPS' ]; then
		section='APPLICATION_GROUPS'
		continue
	fi
	
	if [ "$section" = 'APPLICATIONS' ]; then
		app="$(cut -d ' ' -f 1 <<< "$line ")"
		apps+=($app)
		ALL.add "$app"
		eval app $line
	elif [ "$section" = 'APPLICATION_GROUPS' ]; then
		if [ ${line:0:6} = 'group=' ]; then
			appGroup="${line:6}"
			appGroups+=("$appGroup")
			#appGroup $(convertHyphens "$appGroup")
			appGroup "$appGroup"
		else
			$appGroup.add "$line"
		fi
	else
		eval $line
	fi
	
done < "$CONFIG_FILE"

# Implementation: Let user choose from:
# manual/automatic install/backup here
# If automatic: Ask user to choose from 'apps', 'recovery', or 'both'

###################
#  END OF SCRIPT  #
# USER INPUT HERE #
###################

# User can remain in script & 
# input extra commands or exit script here.
echo
echo "End of script!"
echo
echo "You can manually run extra commands within the script or type 'exit' to quit."
echo "TO BE IMPLEMENTED: Type 'help' to get help on custom script commands."
while
echo -n ": "
read userIn
do
	if [ "$userIn" = 'help' ]; then
		echo "Help function should be called..."
	else
		eval $userIn
	fi
done


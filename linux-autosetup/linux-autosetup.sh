#!/bin/bash

# Default variable fallbacks

# Working directory that script resets to after every install script
# in case installCommand uses cd
declare SCRIPT_WORKING_DIR=$(pwd)
# Where application backups go
declare APP_BACKUP_DIR=./app-backups
# Where recovery files go
declare REC_BACKUP_DIR=./recovery
# Default install command used if one is not specified for app
declare defaultInstallCommand='echo User must set defaultInstallCommand. "name" will not be installed until this is done.'

# Source app and rec class files
. classes/app.h
. classes/rec.h

# Import options.conf
. options.conf


# Used to determine if lines
# in apps files should be skipped.
apps_shouldSkipLine() {
	if [[ $1 = '' || ${1:0:1} = '#' ]]; then
		echo 'true'
	else
		echo ''
	fi
}
# String converter methods to allow functionality with Bash
# Convert from/to '-' & '1_1'
convertFromHyphen() {
	echo ${1//-/1_1}
}

convertToHyphen() {
	echo ${1//1_1/-}
}

# Stores applications as keys
# Stores any params "app strings" as data
declare -Ag apps
# Stores app groups as keys
# Stores apps as data separated by spaces
declare -Ag appGroups
# Import apps.conf
# Skips lines that do not need to be parsed
# Detects and assigns apps to groups
while IFS= read -r line; do
	if [ $(apps_shouldSkipLine "$line") ]; then
		continue
	fi
	
	if [ "$line" = 'APPLICATIONS' ]; then
		section='APPLICATIONS'
		continue
	elif [ "$line" = 'APPLICATION_GROUPS' ]; then
		section='APPLICATION_GROUPS'
		continue
	fi
	
	if [ $section = 'APPLICATIONS' ]; then
		apps[$(convertFromHyphen "$(cut -d ' ' -f 1 <<< "$line ")")]=$(cut -d ' ' -f 2- <<< "$line ")
	elif [ $section = 'APPLICATION_GROUPS' ]; then
		if [ ${line:0:6} = 'group=' ]; then
			appGroup=${line:6}
			continue
		else
			appGroups[$appGroup]+="$line "
			continue
		fi
	fi
	
done < "apps.conf"

# Split app string into parameters for constructor
# $1 = app string, $2 = field
splitAppString() {
	declare appString=$1
	if [ "$appString" = '' ]; then
		return
	fi
	declare -i appStringField=$2
	if [ $2 -eq 1 ]; then
		appString=${appString#*'"'}
		appString=${appString%%'"'*}
	elif [ $2 -eq 2 ]; then
		appString=${appString%'"'*}
		appString=${appString##*'"'}
	else
		echo "Error: splitAppString() took an invalid field #. Exiting..."
		exit
	fi
	echo $appString
}

# Initialize app objects from apps array
for app in "${!apps[@]}"; do
	app $app
	appInstallCommand="$(splitAppString "${apps[$app]}" 1)"
	appBackupSources="$(splitAppString "${apps[$app]}" 2)"
	if [ "$appInstallCommand" = "$appBackupSources" ]; then
		appBackupSources=''
	fi
	$app.constructor "$appInstallCommand" "$appBackupSources"
done




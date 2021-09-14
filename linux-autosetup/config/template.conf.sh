##########################
# CONFIGURABLE VARIABLES #
##########################

# DEFAULT_APP_BACKUP_TYPE="COPY"

# APP_BACKUP_DIR="./app-backups"

# DEFAULT_APP_INSTALL_COMMAND="echo User must set DEFAULT_APP_INSTALL_COMMAND in configuration file. $name will not be installed until this is done."

# DUMP_DIR="./dump"

################
# APPLICATIONS #
################

# App "appname" "one-liner custom install command" "dir/or/files/to/backup;;other/separated/by/2semicolons" "backupType:COPY,HARDLINK"

######################
# APPLICATION GROUPS #
######################

appGroups=(
	[Template]="
		app1
		app2
		app3
	"
)

runAtEnd() {
	return
}

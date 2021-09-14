##########################
# CONFIGURABLE VARIABLES #
##########################

# default install command used if one is not specified for app
# $name will be substituted with app name.
DEFAULT_APP_INSTALL_COMMAND="echo User must set DEFAULT_APP_INSTALL_COMMAND in configuration file. $name will not be installed until this is done."

# Default backup type of apps
# COPY copies files, HARDLINK hard links files
# Hard-linking saves drive space, but may break backups.
# Only use HARDLINK if you understand what it does.
# Backup types: "COPY", "HARDLINK"
DEFAULT_APP_BACKUP_TYPE="COPY"

# Directory where application backups will go
APP_BACKUP_DIR="./app-backups"

# Directory where old backups are dumped
# NOTE: Script does not overwrite, so it may create multiple dumps.
# e.g. .../dump/1 exists, so dump to .../dump/2
# Internal default is "./dump"
# Below is an alternative path to Trash
DUMP_DIR="$HOME/.local/share/Trash/files/linux-autosetup/dump"

################
# APPLICATIONS #
################

# App "appname" "one-liner custom install command" "dir/or/files/to/backup;;other/separated/by/2semicolons" "backupType:COPY,HARDLINK"
# Name "appname" whatever is used in the installCommand - if this is
# not relevant, then you can name it whatever you want
# Parameters are optional. "" represents default - use to skip params

# Example 1
App example "youtube-dl.install; echo this command is being run in installCommand for example app" "HARDLINK" "./example/some-dir/" "./example2/some-file"
App example2 ""
App example3

# general
App clamtk
App discord "flatpak install com.discordapp.Discord"
App file-roller
App firefox "" "COPY" "$HOME/.mozilla/firefox/some-profile"
App gnome-extensions
App gnome-tweaks
App obs-studio
App thunderbird
App tlp
App wine # this should work, but visit https://www.winehq.org/ and use the installCommand for your specific distro to get a more updated version
App winetricks
# audio
App easyeffects "flatpak install flathub com.github.wwmm.easyeffects"
App ffmpeg
App pavucontrol
App pulseeffects
App quodlibet
# devving
App eclipse
App github-desktop
App intellij
App openjdk-16-jdk
# gaming
#  - github JSubelj/g910-gkey-macro-support - may require: python3-setuptools
App g910-gkeys "" "" "/etc/g910-gkeys/config.json"
App gamemode
# configuration/gpu.txt
App greenwithenvy
App lutris
App piper
# configuration/steam.txt
App steam
# editing tools
App blender
App flowblade
App gifski "sudo apt install cargo; cargo install gifski"
App kdenlive
App krita
App losslesscut
App youtube-dl

######################
# APPLICATION GROUPS #
######################

# Can make it easier to install apps through predetermined
# groups of apps. Apps can be assigned to one or more groups.
# You can call your app groups anything, but be mindful
# since they can cause overlaps with apps or archives and
# produce unwanted results.

appGroups=(
	[Example]="
		example
		example2
		example3
	"
	[Essentials]="
		ffmpeg
		pavucontrol
		wine
		youtube-dl
	"
	[Gnome]="
		gnome-extensions
		gnome-tweaks
		file-roller
	"
	[Video_editors]="
		losslesscut
		kdenlive
	"
	[Gaming]="
		gamemode
		lutris
		piper
		steam
	"
	[Development]="
		github-desktop
		intellij
		openjdk-16-jdk
	"
)

runAtEnd() {
	return
}

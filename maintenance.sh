#!/bin/bash
#            _ __ _
#        ((-)).--.((-))
#        /     ''     \
#       (   \______/   )
#        \    (  )    /
#        / /~~~~~~~~\ \
#   /~~\/ /          \ \/~~\
#  (   ( (            ) )   )
#   \ \ \ \          / / / /
#   _\ \/  \.______./  \/ /_
#   ___/ /\__________/\ \___
#  *****************************
#  * WebMaintenance V 1.000    *
#  * ----------------------    *
#  * Create/Save GIT Web       *
#  * Project using Git server  *
#  * Author: Marsiglietti Remy *
#  * Powered by cv.frogg.fr    *
#  * For Arnaud Marsiglietti   *
#  * Copyright 2015            *
#  *****************************

# TODO : Clean Test GIT Exist (search TODO in this file)

#############
# Script    : Commit & Create a new version auto incremented on Local & Origin server
# Important : - Git version format has to be vX.XXX in project root folder in file version.txt
#             - For save process, Script file has to be started in root folder
#############

#===SERVER INFOS
#Git server address
gIP="xxx"
#Git server port
gPort="xxx"
#Git ssh server User
gUser="xxx"
#Git server directory
gDir="/opt/git/"
#Git project directory
pDir="xxx.git"
#Git userName
gMail="admin@frogg.fr"
#remote directory (relative to this script path)
rDir="public_html/"
#Project version file (in project root folder) 
vFile="version.txt"

#Script file name
scriptFile=${0##*/}

#===COLORS
INFOun="\e[4m"							#underline
INFObo="\e[1m"							#bold
INFb="\e[34m"							#blue
INFr="\e[31m"							#red
INFOb="\e[107m${INFb}"					#blue (+white bg)
INFObb="\e[107m${INFObo}${INFb}"		#bold blue (+white bg)
INFOr="\e[107m${INFr}"					#red (+white bg)
INFOrb="\e[107m${INFObo}${INFr}"		#bold red (+white bg)

NORM="\e[0m"
GOOD="\e[1m\e[97m\e[42m"
OLD="\e[1m\e[97m\e[45m"
CHECK="\e[1m\e[97m\e[43m"
WARN="\e[1m\e[97m\e[48;5;208m"
ERR="\e[1m\e[97m\e[41m"

#==COLOR STYLE TYPE

#echo with "good" result color
good()
{
echo -e "${GOOD}$1${NORM}"
}

#echo with "warn" result color
warn()
{
echo -e "${WARN}$1${NORM}"
}

#echo with "check" result color
check()
{
echo -e "${CHECK}$1${NORM}"
}

#echo with "old" result color
old()
{
echo -e "${OLD}$1${NORM}"
}

#echo with "err" result color
err()
{
echo -e "${ERR}$1${NORM}"
}

#echo with "info" result color
info()
{
echo -e "${INFObb}$1${NORM}"
}

#===FUNCTIONS
#func used to ask user to answer yes or no, return 1 or 0
makeachoice()
	{
	userChoice=0
	while true; do
		check " [ Q ] Do you wish to $1 ?"
		read -p "" yn
		case $yn in
			y|Y|yes|YES|Yes|yeah|YEAH|Yeah|ya|YA|Ya|ja|JA|Ja|O|o|oui|OUI|Oui|oue|OUE|Oue|ouep|OUEP|Ouep)userChoice=1;break;;
			n|N|no|NO|No|non|NON|Non|na|Na|NA)userChoice=0;break;;
			* )err " [ ERROR ] '$yn' isn't a correct value, Please choose yes or no";;
		esac
	done
	return $userChoice
	}

#Check if git project has been initialized (hide result message)
gitExist()
	{
	exist=0
	if git status &> /dev/null;then
		#Git has been found
		exist=1
	fi
	return $exist
	}
	
#===================[ 0 ] SCRIPT MENU=================
#--Process Check param
#VAR create new git project
create=0
for params in $*
do
	IFS=: val=($params)
	case ${val[0]} in
		"-ip")		gIP=${val[1]};;
		"-port")	gPort=${val[1]};;
		"-user")	gUser=${val[1]};;
		"-git")		gDir=${val[1]};;
		"-project")	pDir=${val[1]};;
		"-mail")	gMail=${val[1]};;
		"-remote")	rDir=${val[1]};;
		"-create")	create=1;;
	esac
done	

echo -e "\n*******************************"
echo -e "# $scriptFile"
echo -e "# Create/Save/Update Git project"
echo -e "# v1.000, Powered By Frogg - Copyright 2015"
echo -e "# Call : bash $scriptFile\n"
echo -e "Optional Parameters [Default values]"
echo -e " -create: Create the Git project [NoValuesRequired]"
echo -e " -ip: Origin Server Git Address [$gIP]"	
echo -e " -port: Origin Server Git Port [$gPort]"
echo -e " -user: Origin Server Git User login [$gUser]"
echo -e " -git: Origin Server Git Path [$gDir]"
echo -e " -project: Origin Server Git Project path [$pDir]"
echo -e " -remote: Remote Server Web folder [$rDir]"
echo -e " -mail: User Project Mail [$gMail]"
echo -e " -version: Project version file[$vFile]"
echo -e "*******************************\n"

# Ask if sure to start the script
if makeachoice "Do you wish to continue"; then
	warn " [ END ] End of the script, aborted by user"
	exit
fi

#===================[ 1 ] CREATE PROJECT [ORIGIN]===================
# Create project From Scratch or Existing file require create=1
if [ $create = 1 ]; then
	#check if server git folder exist
	if [ ! -d $gDir$pDir ]; then
		# create git dir (-p for fun)
		mkdir -p $gDir$pDir
		good "Creating Git Project from scratch in folder '$gDir$pDir'"
	else
		good "Found Project Files in folder '$gDir$pDir'" 
	fi
	#Change current folder to git project folder
	cd $gDir$pDir
	#Check if git project has been initialized (hide result message)
	if gitExist;then
		#Create Git project
		git init
		# Set user name and email to local repository
		git config user.name "${gMail%%@*}"
		git config user.email "$gMail"
		# Set git to use the credential memory cache
		git config credential.helper cache
		# Set the cache to time out after 1 hour (setting is in seconds)
		git config credential.helper 'cache --timeout=3600'
		# Allow modification on master branch from remote GIT
		git config receive.denyCurrentBranch ignore
		# Init first commit
		git add .
		git commit -m "Project '$pDir' Init"
		if [ -e $vFile ];then
			version=$(cat $vFile)
		else
			version="v1.000"
			echo $version > $vFile
		fi		
		git tag ${version} -m '${version}'
		
		# success message
		good "Git project '$pDir' has been successfully configured in '$gDir$pDir'" 	
	else
		# already exist message
		warn "Git project '$pDir' already exist in '$gDir$pDir', nothing need to be done" 	
	fi
	#stop script
	exit
fi

#===================[ 2 ] GET OR SAVE PROJECT [REMOTE]===================
#server IP Adress
srvOriginGit=""

# => TODO CLEAN THIS PART
if gitExist;then
	#Get server IP Adress from default configuration
	srvOriginGit=$gIP
	#go to remote dir
	mkdir -p ${rDir}
	cd ${rDir}
	good " [ A ] Project folder is now './${rDir}' !"
	
	if gitExist;then
		#Get server IP Adress from default configuration
		srvOriginGit=$gIP
	else
		#Get server IP Adress from Git configuration
		srvOriginGit=$(git config --get remote.origin.url)
		IFS='@' read -a arraySrv <<< "$srvOriginGit"
		IFS=':' read -a arraySrv2 <<< "${arraySrv[1]}"
		srvOriginGit=${arraySrv2[0]}
	fi	
else
	#Get server IP Adress from Git configuration
	srvOriginGit=$(git config --get remote.origin.url)
	IFS='@' read -a arraySrv <<< "$srvOriginGit"
	IFS=':' read -a arraySrv2 <<< "${arraySrv[1]}"
	srvOriginGit=${arraySrv2[0]}
fi

#Test if Git server port is UP
check "...Checking if GIT Origin server '${srvOriginGit}' is available, please wait..."
if nc -w5 -z ${srvOriginGit} ${gPort} &> /dev/null;then
	good " [ A ] Server Git Origin [${srvOriginGit}:${gPort}] port is opened !"	
else
	err " [ A ] Can't access to Server Git Origin Port [${srvOriginGit}:${gPort}], End of the script"
	exit
fi

#===================GET PROJECT [REMOTE]===================
#If first time case
if gitExist;then
	if git clone ssh://${gUser}@${gIP}:${gPort}/${gDir}${pDir} ./;then
		#Send success message
		good "[ END ] Congratz ! Project has been successfully downloaded to ${rDir} ^_^"
	else
		#Send success message
		err "[ END ] Error while getting Git data from $gIP"
	fi
	#exist script
	exit
fi

#===================SAVE PROJECT [REMOTE]===================
#If project change and need to be save on origin server

#test if version file exist
if [ ! -e $vFile ];then
	err " [ END ] End of the script, cannot find $vFile in ${rDir}"
	exit
fi

# Ask if sure to start the script
if makeachoice "Save a new version of $pDir Project"; then
	warn " [ END ] End of the script, aborted by user"
	exit
fi

#
##################LOCAL GIT
#
##update current version number
oldVersion=$(cat $vFile)
arrVersion=( ${oldVersion//./ } )
version=${arrVersion[0]}"."$(printf "%03d\n" $(expr ${arrVersion[1]} + 1))
##check if incrementation is ok
if [ $version = $oldVersion ]; then
	err " [ A ] An error occurred on version number:\n        $vFile equals git version, $vFile should be equals to git version -1 ! \n        the script stopped"
	exit
else
	echo $version > $vFile
fi

##Capture release title
info "Old version was $oldVersion \n new version is $version"
##Add new file not referenced
info "...adding files please wait..."
git add -A
##Add news file to local git
info "...committing files please wait..."
git commit -a
##Create the new version in git
if git tag ${version} -m '${version}'  &> /dev/null;then
info "...committing tag ${version} please wait..."
else
	if makeachoice "merge Version ${version} cause it already exist in the project"; then
		warn " [ END ] End of the script, aborted by user"
		exit		
	else
		if git tag -d ${version} &> /dev/null;then
			git tag ${version} -m '${version}'
		else
			err " [ END ] An error occurred while deleting tag ${version}, if error occur another time, please contact the administrator"
			exit		
		fi		
	fi
fi
#
##################ORIGIN GIT
#
# Ask if sure to send version origin  GIT
#if makeachoice "save the new version into ORIGIN GIT"; then
#	warn " [ A ] End of the script, aborted by user"
#	exit
#fi
##Send file to centralized GIT server
if git push; then
	##send tags
	git push --tags
else
	err " [ END ] Login error, try again\n         the script stopped"
	exit
fi
#Send success message
good "[ END ] Congratz ! save has been successfully done ^_^"
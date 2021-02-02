#!/usr/bin/env bash

printEmptyLineBeforeThisValue() {
  local fmt="$1"; shift
  printf "\\n$fmt\\n" "$@"
}

printCollectionsByNumbers(){
    i=1;
    param1=("${!1}")
    for each in "${param1[@]}"
    do
        echo "${i}) $each"
        i=$((i+1));
    done
}

installPackage(){
    param1=("${!1}")
    for each in "${param1[@]}"
    do
        if command -v ${each} > /dev/null; then
            echo " $each is already installed, skipping installation"
        else
            brew  install ${each} || echo "$each installation failed, moving on to the next package/cask"
        fi
    done
}

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\\n" "$text" >> "$zshrc"
    else
      printf "\\n%s\\n" "$text" >> "$zshrc"
    fi
  fi
}

append_to_sshconfig() {
	eval "$(ssh-agent -s)"

	createSshConfigFile
	sshConfig="$HOME/.ssh/config"
  	local text="Host *
	AddKeysToAgent yes
  	UseKeychain yes
  	IdentityFile ~/.ssh/id_ed25519"
  	local skip_new_line="${2:-0}"

  if ! grep -Fqs "$text" "$sshConfig"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\\n" "$text" >> "$sshConfig"
    else
      printf "\\n%s\\n" "$text" >> "$sshConfig"
    fi
  fi

  ssh-add -K ~/.ssh/id_ed25519
}

createSshConfigFile(){
	if [ ! -e "$HOME/.ssh/config" ]; then
  		touch "$HOME/.ssh/config"
	fi
}

generateGitSSHKeys(){
	echo "The below is needed for GIT SSH GPG key generation"
	#printf "Enter your salesforce email address: "
	#read salesforceEmail

	echo "When you are prompted tto enter a file in which to save the key, press enter, for default location"

	ssh-keygen -t  ed25519 -C $1
	#ssh-keygen -t  ed25519 -C $salesforceEmail
	append_to_sshconfig
}

addSSHKeyToRemote(){
	echo "Now add the generate keys to your GIT hub account "
	echo  "Follow the steps below, if you need help"
	pbcopy < ~/.ssh/id_ed25519.pub

	echo  "This script has done all the backgroun work for you, just give a name and comman+v, the key on your clipboard into the key location"
	/usr/bin/open -a "/Applications/Google Chrome.app" https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
	/usr/bin/open -a "/Applications/Google Chrome.app" https://git.soma.salesforce.com/settings/ssh/new

	printf "Once you have finished adding your SSH key to your git account press Y: "
	read isSSHKeyAddedToRemoteGitAccount 
	if [ "$isSSHKeyAddedToRemoteGitAccount" == "Y" ] ; then
		echo "Lets move to addind GPG keys for signed commit"
	else
		echo "Please dont forget to do this step, follow the article at a later time"
		/usr/bin/open -a "/Applications/Google Chrome.app" https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
	fi
}

generateGPGKey(){
	gpg --list-secret-keys --keyid-format LONG
	gpg --gen-key

	# create the file, to store the key temporarily, once added to git remote
	# this will be removed by the method addGPGKeyToRemote
	gpg --output public.pgp --armor --export $1
}

addGPGKeyToRemote(){
	pbcopy <  public.pgp
	/usr/bin/open -a "/Applications/Google Chrome.app" https://git.soma.salesforce.com/settings/gpg/new
	printf "Once you have finished adding your GPG key to your git account press Y: "
	read isGPGKeyAddedToRemoteGitAccount 
	if [ "$isGPGKeyAddedToRemoteGitAccount" == "Y" ] ; then
		echo "Well Done!!!"
	else
		echo "Please dont forget to do this step, follow the article at a later time"
		/usr/bin/open -a "/Applications/Google Chrome.app" https://docs.google.com/document/d/1u_HW9MIYse26Saxl2g8cbvxZj6Ja_vO41LBY9vVsHkw/edit#
	fi

	#remove the file created by generateGPGKey method
}

addConfigToGitFile(){
	git config --global user.name "$1"
	git config --global user.email "$2"

	# set gpg rsa key start
	gpg --list-secret-keys --keyid-format LONG  | grep "sec" > gpgSecretKeyFile
	gpgSecretKeyFileSentence=$(<gpgSecretKeyFile)
	stringarray=($gpgSecretKeyFileSentence)
	rsaValueWithSlash=${stringarray[1]}
	IN=${rsaValueWithSlash}
	rsaValueArray=(${IN//// })
	git config --global user.signingkey ${rsaValueArray[1]} 
	# set gpg rsa key end

	append_to_zshrc 'export GPG_TTY=$(tty)'
	git config --global commit.gpgsign true
	git config --global gpg.program gpg
}

printlsa(){
	echo $1
	echo $2
}

gitRepoDownload(){
	printf "Do you want to install GIT repos as well? Type Y or N "
	read isGitRepoInstallation
	echo $isGitRepoInstallation

	if [ "$isGitRepoInstallation" == "Y" ] ; then
		gitRepoInstallation
	else
		echo "Skipping git repo installation step"
	fi
}

gitRepoInstallation(){

	reponames=Appstore_Assets,Appstore_appconfig,COA,Appstore_Cpq,Appstore_COA,Appstore_Document_Utility,Appstore_EntitlementServices,Appstore_Integration,\
Appstore_L10n,Appstore_legalAgreements,Appstore_OrderServices,Appstore_partnerAgreements,Appstore_Proposal,Appstore_QuoteConversion,Appstore_Renewals,\
Appstore_seeddata,Appstore_selfservice,Appstore_Sparta,Appstore_vat,Appstore_OM,Appstore_Entitlements,Appstore_Billing

	gitDir="$HOME/git"
	printf "Salesforce biztech realted GIT repos will be downloaded at $gitDir "
	printf "Do you want Installing to default location? Type Y or N "
	read isInstallingToCurrentLocation

	dirLocation=$gitDir
	if [ "$isInstallingToCurrentLocation" = "Y" ] ; then
		cd $HOME
		mkdir -p -- $dirLocation
		echo "created directory $dirLocation"
	else
		printf "Enter directory name: "
		read dirname
		dirLocation=$dirname/git
		if [ ! -d "$dirLocation" ]
		then
    		echo "Directory doesn't exist. Creating now"
    		mkdir -p -- "$dirLocation"
    		echo "Directory created"
		else
        	echo "Directory exists"
    	fi
	fi

	for reponame in $(echo $reponames | sed "s/,/ /g")
	do
		echo "clong $reponame at $gitDir"
		git clone git@git.soma.salesforce.com:IT/$reponame.git $gitDir/$reponame
	done

}

localGitRepoDownload(){
	gitRepoDownload
}

gitSetup(){
	read  -p "Enter your salesforce user name " salesforceUserName
	read  -p "Enter your salesforce email address: " salesforceEmail
	#print "${salesforceUserName}" "${salesforceEmail}"

	generateGitSSHKeys "${salesforceEmail}"
	addSSHKeyToRemote
	generateGPGKey "${salesforceEmail}"
	addGPGKeyToRemote 
	addConfigToGitFile "${salesforceUserName}" "${salesforceEmail}"
}

allGitRelatedOperations(){
	gitSetup
	localGitRepoDownload
}

update_shell() {
  local shell_path;
  shell_path="$(command -v zsh)"

  printEmptyLineBeforeThisValue "Changing your shell to zsh ..."
  if ! grep "$shell_path" /etc/shells > /dev/null 2>&1 ; then
    printEmptyLineBeforeThisValue "Adding '$shell_path' to /etc/shells"
    sudo sh -c "echo $shell_path >> /etc/shells"
  fi
  sudo chsh -s "$shell_path" "$USER"
}

nvmDirectoryWithNodeInstallation(){
	echo "we are installing nodejs now: "
	if [ ! -d ~/.nvm ]; then
	  	echo "Create a new directory for NVM "
	  mkdir ~/.nvm
	fi

	append_to_zshrc 'export NVM_DIR=~/.nvm'
	append_to_zshrc 'source $(brew --prefix nvm)/nvm.sh'
	source ~/.zshrc
	nvm install --lts
}

installSalesforceExtensionPackForVSCode(){
	code --install-extension salesforce.salesforcedx-vscode
}

packageInstallSteps(){
	# shellcheck disable=SC2154
	trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

	set -e

	if [ ! -d "$HOME/.bin/" ]; then
	  mkdir "$HOME/.bin"
	fi

	if [ ! -f "$HOME/.zshrc" ]; then
	  touch "$HOME/.zshrc"
	fi

	# shellcheck disable=SC2016
	append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

	HOMEBREW_PREFIX="/usr/local"

	if [ -d "$HOMEBREW_PREFIX" ]; then
	  if ! [ -r "$HOMEBREW_PREFIX" ]; then
	    sudo chown -R "$LOGNAME:admin" /usr/local
	  fi
	else
	  sudo mkdir "$HOMEBREW_PREFIX"
	  sudo chflags norestricted "$HOMEBREW_PREFIX"
	  sudo chown -R "$LOGNAME:admin" "$HOMEBREW_PREFIX"
	fi

	case "$SHELL" in
	  */zsh)
	    if [ "$(command -v zsh)" != '/usr/local/bin/zsh' ] ; then
	      update_shell
	    fi
	    ;;
	  *)
	    update_shell
	    ;;
	esac

	CASKS=(
	    adoptopenjdk
	    maven
	    atom
	    slack
	    github
	    visual-studio-code
	    intellij-idea
	)

	PACKAGES=(
	    ack
	    ant
	    autoconf
	    automake
	    findutils
	    git
	    gnupg
	    npm
	    nvm
	    pkg-config
	    postgresql
	    the_silver_searcher
	    vim
	    wget
	)

	printEmptyLineBeforeThisValue " ######################################## CASK Installation ########################################"
	printCollectionsByNumbers CASKS[@]
	printEmptyLineBeforeThisValue " ######################################## PACKAGE Installation ########################################"
	printCollectionsByNumbers PACKAGES[@]

	read -p "Do you really want to install all the above softwares (Build ${BUILD}, x${BITS}) on your machine? [Y/n]: " CONFIRM
	CONFIRM=$(printEmptyLineBeforeThisValue "${CONFIRM}" | tr [a-z] [A-Z])
	if [[ "${CONFIRM}" = 'N' ]] || [[ "${CONFIRM}" = 'NO' ]]; then
	    printEmptyLineBeforeThisValue "Aborted!"
	    exit
	fi


	# Check for Homebrew, install if we don't have it
	if test ! $(which brew); then
	    printEmptyLineBeforeThisValue "Installing package manager (Homebrew) for your Mac OS"
	    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	    append_to_zshrc '# Homebrew'
	    append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1
	    export PATH="/usr/local/bin:$PATH"
	fi

	brew update


	printEmptyLineBeforeThisValue "Installing cask apps..."
	installPackage CASKS[@]

	printEmptyLineBeforeThisValue "Installing packages..."
	installPackage PACKAGES[@]

	nvmDirectoryWithNodeInstallation
	installSalesforceExtensionPackForVSCode
	printEmptyLineBeforeThisValue " ######################################## Machine setup complete ########################################"

	# for compilers to find open jdk
	append_to_zshrc 'export CPPFLAGS="-I/usr/local/opt/openjdk/include"'

}

executeAllSteps(){
	packageInstallSteps
	allGitRelatedOperations
	echo "Execution of steps is complete"
}

menuPrint(){
	printf "The script will do the following:
 Type ALL to execute all of the steps 
 (or) type the required step number to perform that particular step

 ############################# Options begins here ############################
 A) Type (A)ll, to do all of the process below in one single operation
 1) Install Biztech related softwares,
    Update the path your profile, i.e. bash_profile, zprofile, zshrc etc....
    Based on your computer architecture
 2) Setup GIT local setup: Generate SSH Keys
 3) Setup GIT Remote setup: Add SSH Keys to remote GIT
 4) Setup GIT local setup: Generate GPG Keys
 5) Setup GIT Remote setup: Add GPG Keys to remote GIT
 6) Type 6, to do git source code repo downloads alone
 7) Type 7, to do the entire GIT related operation from 2 to 6

 M) Type (M)enu, to see this menu again
 E) Type (E)xit to exit this process

 ############################# Options ends here ############################

 Note: All of the operations specified above will take care of all the backend related work like,
 Updating GITCONFIG, usr/local/ path setup, fixing to be avaiable to all, appaending the profile for the user

 The scipt is intelligent enough to detech which OS is running and to which shell profile it needs to append to.
 "
}

mainMenuPrinter(){
	printEmptyLineBeforeThisValue "############### Step No: ${1}, which you requested is done, press M to see the main nenu again ################"
}

getRSAGPGName(){
	gpg --list-secret-keys --keyid-format LONG  | grep "sec" > gpgSecretKeyFile
	gpgSecretKeyFileSentence="sec   rsa3072/642148F851E455EA 2021-02-02 [SC] [expires: 2023-02-02]"
	stringarray=($gpgSecretKeyFileSentence)
	rsaValueWithSlash=${stringarray[1]}
	IN=${rsaValueWithSlash}
	rsaValueArray=(${IN//// })
	echo ${rsaValueArray[1]} 
}

#identifies your machine processor types
if [[ "$(uname -m)" = "x86_64" ]]; then
    BITS=64
else
    BITS=32
fi

printEmptyLineBeforeThisValue "############### Welcome ${USER} ################"
printEmptyLineBeforeThisValue "The script has identified you are using a ${BITS} architecture system"

menuPrint


while :
do
  
  read userChoice
  case $userChoice in
        A)
                executeAllSteps
                mainMenuPrinter "${userChoice}"
                ;;
        M)
                menuPrint
                ;;
        E)
                echo "Exiting"
                break
                ;;
        1)
                packageInstallSteps
                mainMenuPrinter "${userChoice}"
                ;;
        2)
				#print"username" username
				getRSAGPGName
				mainMenuPrinter "${userChoice}"
                ;;
        3)
                echo "See you again!"
                mainMenuPrinter "${userChoice}"
                ;;
        4)
                echo "See you again!"
                mainMenuPrinter "${userChoice}"
                ;;
        5)
                echo "See you again!"
                mainMenuPrinter "${userChoice}"
                ;;
        6)
				localGitRepoDownload
                mainMenuPrinter "${userChoice}"
                ;;
        7)
                allGitRelatedOperations
                mainMenuPrinter "${userChoice}"
                ;;
        *)
                echo "Sorry, I don't understand"
                ;;
  esac
done
echo 
echo "Machine steup done"
#gitSetup
#localGitRepoDownload


# check gpg keuys
# gpg --list-secret-keys --keyid-format LONG
# to delete
# gpg --delete-secret-key 604056D6EECC88F3
# gpg --delete-key BB21E0F0D6CE5615 

# to delete ssh keys
# go to useer ho
 # /Users/gdeivasigamani/.ssh
# then delete by using below
# 

############### Important ################
# To uninstall homebrew run below
# /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"

# to add to path and file same time
# echo -n 'export PATH=~/bin:$PATH' >> ~/.zshrc
# echo  'export PATH=$PATH'  >> ~/.zprofile


# defaul Path incase ever want to rever the path
# https://superuser.com/posts/121885/revisions
# $ PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
# $ PATH=/usr/bin:/bin:/usr/sbin:/sbin
# $ export PATH


# Brew GUI CASK
# https://github.com/Homebrew/homebrew-cask/blob/master/USAGE.md

# Major command
#install — installs the given Cask
# uninstall — uninstalls the given Cask
# reinstall — reinstalls the given Cask
# list --casks — lists installed Casks

#reference:
#  https://github.com/thoughtbot/laptop/blob/master/mac

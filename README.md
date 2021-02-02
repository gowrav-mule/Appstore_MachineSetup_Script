# Appstore MachineSetup Script

# How to use this machine setup
This proejct has been deisgned and implamented in such a way to automate the entire machine setup needed for users. <br/>
Just type the below two commands to execute and complete the machine setup in your machine

1. Make sure you are <br/>
      
             1. Logged into Salesforce VPN
             2. Aloha TMP tile is clicked

1. Download this repo, or just the `machineSetup.sh` file to your local machine
Then run the below two commands, to kick start the setup process: <br/>
      
             1. Give it permission to run
                $> chmod 755 machineSetup.sh
             2. Execute the script 
                $> ./machineSetup.sh

Thats it !!!!
If you are really intrested in all the steps of the script please see below
------------------------------

### Software Installation:

1. Scripts check if your machine is 32 or 64 Bit architecture
1. It intelliegently determines, wheter it needs to act on `zshrc` or `bash_profile` based on your system architecture and configuration. <br/>
It appends to the above files in a intelligent manner.
1. Checks if the system has Hombrew installed
 
        1. If Homebrew is present, it will update homebrew to latest version
        2. If Homebrew is not present, the script will automatically install it
1. Sets the proper HOMEBREW path i.e. /usr/local
1. Changes the current working shell to zsh
1. Installs GUI based sfotwares and places them under the application folder using Homebrew cask <br/>
[The script will intelligently skip the installations for already installed applications]
      1. OpenJDK
      1. Maven
      1. Atom
      1. Slack
      1. Github
      1. Other softwares with cask can be easily added to this script, just add them to `cask` variable in the script
         ![Script casks](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/casks.png)

1. Installs command line softtware packages via homebrew.<br/>
[The script will intelligently skip the installations for already installed applications]
      1. ack
      1. ant
      1. acutoconf
      1. automake
      1. findutils
      1. gnupg
      1. npm
      1. nvm
      1. pkg-config
      1. postgresql
      1. Silver searcher
      1. vim
      1. wget
      1. Other softwares can be easily added to this script, just add them to the `packages` variable in the script
         ![script packages](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/packages.png)
1. The script also detects if a softtware is already pre-installed, if it is, it will skip the installation process
1. Sets `/usr/local/bin:$PATH` to the appropriate shell file
1. After installing, node version manager (nvm), the scripts appends the nvm to the shell profile and then it starts download the latest nodejs
1. Sets openJDK ` export CPPFLAGS="-I/usr/local/opt/openjdk/include"` to the appropriate shell file
1. The scrip intelligently updates/creates/appends the OS Sepcific Shell profile, with the requried values
   ![System Zshel Zshrc](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/zshrc.png)


### Git related setups
1. At a high level the below steps are done    
    1. **Local:** It will add the  SSH key to SSH-Agent <br/>
    1. **Github Account remote:** It will Add the new SSH key to your Github account <br/>
    1. **Local:** It will generate a new GPG key to your local machine <br/>
    1. **Github Account remote::** It will add the newly generated GPG key to your Github Account <br/>
    
1. The script will generate SSH keys for you and will setup your local machine with the proper values, i.e. <br/>
`SSH keys are generated : cd /Users/gdeivasigamani/.ssh` <br/>
    1. It will add the  SSH key to SSH-Agent <br/>
    1. It will Add the new SSH key to your Github account <br/>
    1. It will generate a new GPG key to your local machine <br/>
    1. It will add the newly generated GPG key to your Github Account <br/>
    ![Git SSH Key Locally](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/SSH%20Keys.png)


1. The script will automatically copy the SSH key value to your clipboard and re-direct you to https://git.soma.salesforce.com/settings/ssh/new
    ![Github account ssh key page](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/Github%20account%20ssh%20key%20page.png)

     1. [Generating a new SSH key and adding it to the ssh-agent](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent "Generating a new SSH key and adding it to the ssh-agent")

     1. [Adding a new SSH key to your GitHub account](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account "Adding a new SSH key to your GitHub account")
        <br/> Your Clipboard will already have the required SSH Key in its local memory.
1. The script will take care of GPG key generation in your local machine
      1. `gpg --list-secret-keys --keyid-format LONG`
      1. `gpg --gen-key`
      1. `gpg --output public.pgp --armor --export <youremailid>`
      ![Git GPG Key Locally](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/gpg%20key.png)

1. Add the newly created GPG key to your Github Account<br/>
       The script will re-direct you to the URL https://git.soma.salesforce.com/settings/gpg/new. <br/>
       ![Github account gpg key page](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/Github%20account%20gpg%20key%20page.png)
       Your Clipboard will already have the required GPG Key in its local memory.
    
1. The script in the backends intellignetly detects the SSH and GPG Key <br/>
    Note: Currently this script assumes, the machine it runs under doesnt have any pre-generated SSH or GPG keys</br>
    If your machine has them, please mofdofy the script or contact @gowrav deivasigamani<br>
1. The script will now work on the gitconfig file and append the below values <br/>
    `vi ~/.gitconfig`
    <br/>
    ![Git config](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/gitconfig.png)

### Git repository setups
1. Once all installtions in the previous setup is complete and successful, the script will promt the user for permission to commence Appstore_Biztech source 
code repo downloads
2. The following repo's will be download by the script


            1. Appstore_Assets
            2. Appstore_appconfig
            3. COA 
            4. Appstore_Cpq 
            5. Appstore_COA 
            6. Appstore_Document_Utility 
            7. Appstore_EntitlementServices
            8. Appstore_Integration
            9. Appstore_L10n,
            10. Appstore_legalAgreements
            11. Appstore_OrderServices 
            12. Appstore_partnerAgreements
            13. Appstore_Proposal
            14. Appstore_QuoteConversion
            15. Appstore_Renewals
            16. Appstore_seeddata
            17. Appstore_selfservice
            18. Appstore_Sparta,Appstore_vat
            19. Appstore_OM
            20. Appstore_Entitlements
            21. Appstore_Billing
            22. Other Repo's can be easily added to this script, just add them to the `reponames` variable in the script
             
     ![script reponames](https://git.soma.salesforce.com/gdeivasigamani/Appstore_MachineSetup_Script/blob/master/visuals/Images/reponames.png)

2. The user can give a custom directoy to install the repo's that are going to be cloned, or else, the repo's above repo's will be cloned to the default directory, i.e. <br/>
`USER_HOME/git` <br/>
Example: `/Users/gdeivasigamani/git'

### References/Credits:
1. https://github.com/thoughtbot/laptop/blob/master/mac
2.  https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
3. https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
4. https://docs.google.com/document/d/1u_HW9MIYse26Saxl2g8cbvxZj6Ja_vO41LBY9vVsHkw/edit#
5. https://brew.sh/

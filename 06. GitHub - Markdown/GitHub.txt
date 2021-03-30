# Using Github with R Studio.

First thing you should have a Github account. If you do not, then navigate to github.com and create one. Github has Repositories that allow you to store and create code along with other files like pdfs, powerpoints, word documents, etc. The power of using Github and R is that you can easily store code by saving it to the cloud or pull projects you or others have and run them quickly.

## First some basics. 

Pull commands allow us to pull down code from a public Git repository. The easiest way to do this is create an R Project and make it link to the repository you want to bring in. In this case it is: https://github.com/mattdemography/STA_6233_Spring2021 or https://github.com/mattdemography/DA_6223_Spring2021.

## See if you have git installed - you should
Type "git --version" into the Terminal. If you seen an error then navigate to: "https://happygitwithr.com/install-git.html"

Navigate to File -> New Project -> Version Control -> Git -> and paste the link above into the gitrepo field.
Now you will have all of the course materials in an R project. This project is static - it will not change as new items are put into the folder.

## In order to make sure you are seeing the newest versions of items you will use:
system("git pull https://github.com/mattdemography/STA_6233")

Note that the system() function sends items to the Terminal. You can type in that line into a terminal without the system() wrapper and get the same result.

## Using Your Own Code
Now What if you don't just want to bring in other repositories, but instead use your own so that you can quickly save code when needed?

To do this you will need to tell RStudio and Github that this is your account and you have permissions to make changes to the repository.
To do this we use a SSH key. These keys should not be posted anywhere and you should only call them when needed as they give access to your system and your git account.

system("git config --global user.email \"mjmpoetry@gmail.com\"")  #Add your github email
system("git config --global user.name \"mattdemography\"")        #Add your github username
system("git config --list")                                       #Check your settings
"ssh-keygen -t rsa -C mjmpoetry@gmail.com"                        #Generate your Keys
"cat ~/.ssh/id_rsa.pub"                                           #Copy SSH public key to place in github

### Alternatively 
go to Tools -> Global options -> Git SVN -> View public key and copy the key to your Github account setting (Edit profile / SSH keys / Add SSH key).

https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

Now we can pull and push our own repositories to keep up with verison control.
#! /usr/bin/env bash

brew install coreutils

# Upgrade git and install related apps
sudo mv /usr/bin/git /usr/bin/git-apple
brew install git
brew link --force git
brew install git-flow diff-so-fancy
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"

# the command-line based apps
brew install vim ag wget tree jq httpie


# docker session
brew cask install docker
brew install ctop dive
#bres istall docker-machine

# the gui-based tools
brew cask install iterm2 spectacle atom slack pycharm

#brew cask install ngrok

# misc
brew install tldr


# upgrade bash
brew install bash
sudo sh -c "echo '/usr/local/bin/bash  # Bash upgrade on macOS' >> /etc/shells"

# if you want to use bash as your default shell, run the following line
# chsh -s /usr/local/bin/bash $USER

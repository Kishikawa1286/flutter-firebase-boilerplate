#!/bin/bash

# Container initialization script

ask_user() {
  while true; do
    read -p "$1 [y/n]: " answer
    case $answer in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer y or n.";;
    esac
  done
}

# Login to Firebase
if ask_user "Do you want to login to Firebase?"; then
  firebase login --no-localhost
fi

# Login to Google Cloud
if ask_user "Do you want to login to Google Cloud?"; then
  gcloud auth login --no-launch-browser
fi

# Set up Git
if ask_user "Do you want to set up Git?"; then
  read -p "Please enter your Git user name: " GIT_USERNAME
  git config --global user.name "$GIT_USERNAME"
  read -p "Please enter your Git email address: " GIT_EMAIL
  git config --global user.email "$GIT_EMAIL"
fi

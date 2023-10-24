#!/bin/sh

# Login to Firebase
firebase login --no-localhost
 
# Login to Google Cloud
gcloud auth login --no-launch-browser

# Set up Git
read -p "Please enter your Git user name: " GIT_USERNAME
git config --global user.name "$GIT_USERNAME"
read -p "Please enter your Git email address: " GIT_EMAIL
git config --global user.email "$GIT_EMAIL"

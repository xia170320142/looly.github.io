#!/bin/bash

# Push to github
git push origin master

# Switch to branch coding-pages
git checkout coding-pages
# Merge from master
git merge master
# Push to remote coding-pages
git push coding coding-pages
# Return master
git checkout master

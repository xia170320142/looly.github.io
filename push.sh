#!/bin/bash

# Push to github
git push origin master

# Push to gitcafe
git checkout gitcafe-pages
# Merge master content
git merge master
# Push to remote gitcafe-pages branch
git push gitcafe gitcafe-pages
# Return
git checkout master

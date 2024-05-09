#!/bin/bash

function add_metadata ()
{
  git pull
  git add "*.json"
  git commit -m "added metadata from images"
  git push
}

branch=$(git branch --show-current)
metadata_branch="metadata"

if [[ $branch != $metadata_branch ]]; then
  git add .
  git stash
  git switch $metadata_branch
  add_metadata
  git switch -
  git stash apply
else
  add_metadata
fi

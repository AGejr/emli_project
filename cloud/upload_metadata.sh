#!/bin/bash

function add_metadata ()
{
  git reset
  git add "*.json"
  git commit -m "added metadata from images"
  git pull
  git push
}

branch=$(git branch --show-current)
metadata_branch="metadata"

if [[ $branch != $metadata_branch ]]; then
  git switch $metadata_branch
  add_metadata
  git switch -
else
  add_metadata
fi

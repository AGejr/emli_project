#!/bin/bash

git_repo_path=$(git rev-parse --show-toplevel)
images_local_path="$git_repo_path/images/"
image_files=$(find $images_local_path -type f -name '*.jpg')

for image_path in $image_files
do
  metadata_path=$(echo $image_path | sed 's/jpg/json/')
  if [[ ! -a $metadata_path ]]; then
    echo "No metadata for $image_path"
    continue
  fi
  echo "Describing $image_path"
  prompt="describe $image_path using valid utf-8 characters and use json format"
  annotation_data=$(ollama run llava:7b --format json --nowordwrap $prompt 2>/dev/null)
  metadata=$(cat $metadata_path)
  jq -s '.[0] * {annotations: .[1]}' <(echo "$metadata") <(echo "$annotation_data") > "$metadata_path"
  echo "Annotated $image_path"
done

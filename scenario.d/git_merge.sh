#!/bin/bash
# Script for doing merging between src(or new_data) and data branches
# Shall always be called from data branch

set -e # fail fast

# Parsing help
help_script()
{
cat << EOF
Usage: $0 options

Script for running kernel that measures caches

OPTIONS:
   -h      Show this message
   -b      Name of the other branch with whome we are branching
   -m      Merging with master branch
EOF
}
# Parsing options
while getopts "b:mh" opt; do
  case $opt in
    m)
      branchname="master"
      ;;
    b)
      branchname=$OPTARG
      ;;
    h)
      help_script
      exit 4
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      help_script
      exit 3
      ;;
  esac
done

current_branch=$(git symbolic-ref --short HEAD)
echo "Now you are in git branch: ${current_branch}"
# Checking the name of the branch is data
if [[ "$current_branch" != data ]]; then
    echo "ERROR-cannot do merging if we are not in data branch!"
    exit 1
fi

if git diff-index --quiet HEAD --; then
    echo "Everything is commited in this branch"
else
    echo "ERROR-need to commit everything in this branch before merging!"
    git status
    exit 2
fi

root=""
changes=""
# Getting the common ancestor
root=$(git merge-base master $branchname)
set +e # For NULL case
# Getting the files with differences
changes=$(git diff --name-only $root $branchname | grep -v data | grep -v LabBook | grep -v .starpu)
set -e
if [ -n "$changes" ]; then
    echo "ERROR-Changes to source/R inside new data branch!"
    echo $changes
    echo "Do the revert of source/R changes inside ${branchname}"
    exit 3
fi

git merge $branchname -s recursive -Xours -m "Merging with $branchname branch"

echo "MERGING IS DONE SUCCESSFULLY!"
